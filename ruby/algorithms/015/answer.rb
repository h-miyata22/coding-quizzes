require 'time'

class DataPoint
  attr_reader :value, :timestamp, :metadata

  def initialize(value:, timestamp: Time.now, metadata: {})
    @value = value
    @timestamp = timestamp
    @metadata = metadata
  end
end

class SlidingWindow
  def initialize(size_limit: nil, time_limit: nil)
    @size_limit = size_limit
    @time_limit = time_limit
    @data = []
    @sum = 0.0
    @sum_squared = 0.0
  end

  def add(data_point)
    @data << data_point
    @sum += data_point.value
    @sum_squared += data_point.value**2

    # ウィンドウサイズの制限を適用
    clean_window
  end

  def remove_oldest
    return nil if @data.empty?

    oldest = @data.shift
    @sum -= oldest.value
    @sum_squared -= oldest.value**2
    oldest
  end

  def mean
    return 0 if @data.empty?

    @sum / @data.size
  end

  def variance
    return 0 if @data.empty?

    n = @data.size
    mean_val = mean
    (@sum_squared / n) - (mean_val**2)
  end

  def std_dev
    Math.sqrt(variance)
  end

  def median
    return 0 if @data.empty?

    sorted_values = @data.map(&:value).sort
    mid = sorted_values.size / 2

    if sorted_values.size.odd?
      sorted_values[mid]
    else
      (sorted_values[mid - 1] + sorted_values[mid]) / 2.0
    end
  end

  def percentile(p)
    return 0 if @data.empty?

    sorted_values = @data.map(&:value).sort
    index = (sorted_values.size - 1) * p / 100.0
    lower = sorted_values[index.floor]
    upper = sorted_values[index.ceil]

    lower + (upper - lower) * (index - index.floor)
  end

  def size
    @data.size
  end

  def values
    @data.map(&:value)
  end

  def latest
    @data.last
  end

  def oldest
    @data.first
  end

  private

  def clean_window
    current_time = Time.now

    # サイズ制限
    remove_oldest while @size_limit && @data.size > @size_limit

    # 時間制限
    return unless @time_limit

    remove_oldest while @data.any? && (current_time - @data.first.timestamp) > @time_limit
  end
end

class StreamProcessor
  def initialize(window_size: 100, time_window: nil)
    @window = SlidingWindow.new(size_limit: window_size, time_limit: time_window)
    @rules = {}
    @alerts = []
    @processed_count = 0
    @anomaly_detector = AnomalyDetector.new
  end

  def add_rule(name, threshold: nil, change_rate: nil, z_score: nil)
    @rules[name] = {
      threshold: threshold,
      change_rate: change_rate,
      z_score: z_score
    }
  end

  def process(data_point)
    @window.add(data_point)
    @processed_count += 1

    # ルールベースの異常検出
    check_rules(data_point)

    # 統計的異常検出
    return unless @window.size >= 10 # 十分なデータがある場合

    check_statistical_anomalies(data_point)
  end

  def get_statistics
    {
      mean: @window.mean.round(2),
      median: @window.median.round(2),
      std_dev: @window.std_dev.round(2),
      variance: @window.variance.round(2),
      min: @window.values.min || 0,
      max: @window.values.max || 0,
      count: @window.size,
      total_processed: @processed_count,
      percentile_95: @window.percentile(95).round(2)
    }
  end

  def get_alerts(limit: nil)
    if limit
      @alerts.last(limit)
    else
      @alerts
    end
  end

  def clear_alerts
    @alerts.clear
  end

  def get_trend
    return :stable if @window.size < 5

    # 簡易的な線形回帰で傾向を判定
    values = @window.values
    n = values.size
    x_sum = (0...n).sum
    y_sum = values.sum
    xy_sum = values.each_with_index.sum { |y, x| x * y }
    x_squared_sum = (0...n).sum { |x| x * x }

    # 傾き
    slope = (n * xy_sum - x_sum * y_sum).to_f / (n * x_squared_sum - x_sum * x_sum)

    # 傾きの大きさで判定
    if slope > 0.1
      :increasing
    elsif slope < -0.1
      :decreasing
    else
      :stable
    end
  end

  private

  def check_rules(data_point)
    @rules.each do |name, rule|
      # 閾値チェック
      if rule[:threshold] && data_point.value > rule[:threshold]
        add_alert(name, data_point, "Value #{data_point.value} exceeds threshold #{rule[:threshold]}")
      end

      # 変化率チェック
      if rule[:change_rate] && @window.size >= 2
        previous = @window.values[-2]
        change = (data_point.value - previous).abs / previous.abs

        add_alert(name, data_point, "Rapid change detected: #{(change * 100).round(1)}%") if change > rule[:change_rate]
      end

      # Zスコアチェック
      next unless rule[:z_score] && @window.size >= 10

      z = calculate_z_score(data_point.value)

      add_alert(name, data_point, "Z-score #{z.round(2)} exceeds threshold") if z.abs > rule[:z_score]
    end
  end

  def check_statistical_anomalies(data_point)
    # IQR（四分位範囲）による外れ値検出
    q1 = @window.percentile(25)
    q3 = @window.percentile(75)
    iqr = q3 - q1

    lower_bound = q1 - 1.5 * iqr
    upper_bound = q3 + 1.5 * iqr

    if data_point.value < lower_bound || data_point.value > upper_bound
      add_alert(:iqr_outlier, data_point, "Value outside IQR bounds [#{lower_bound.round(2)}, #{upper_bound.round(2)}]")
    end

    # 移動平均からの乖離
    return unless @window.size >= 20

    recent_mean = @window.values.last(10).sum / 10.0
    overall_mean = @window.mean

    return unless (recent_mean - overall_mean).abs > 2 * @window.std_dev

    add_alert(:mean_shift, data_point, 'Significant mean shift detected')
  end

  def calculate_z_score(value)
    mean = @window.mean
    std_dev = @window.std_dev

    return 0 if std_dev == 0

    (value - mean) / std_dev
  end

  def add_alert(type, data_point, message)
    @alerts << {
      type: type,
      value: data_point.value,
      timestamp: data_point.timestamp,
      message: message,
      statistics: get_statistics
    }
  end
end

class AnomalyDetector
  def initialize(sensitivity: 2.0)
    @sensitivity = sensitivity
    @change_points = []
  end

  def detect_change_point(values)
    return nil if values.size < 20

    # CUSUM（累積和）アルゴリズムの簡易版
    mean = values.sum / values.size
    cusum_pos = 0
    cusum_neg = 0

    values.each_with_index do |value, i|
      cusum_pos = [0, cusum_pos + value - mean].max
      cusum_neg = [0, cusum_neg + mean - value].max

      threshold = @sensitivity * Math.sqrt(values[0..i].sum { |v| (v - mean)**2 } / (i + 1))

      if cusum_pos > threshold || cusum_neg > threshold
        @change_points << i
        return i
      end
    end

    nil
  end
end

# テスト
if __FILE__ == $0
  processor = StreamProcessor.new(window_size: 50, time_window: nil)

  # 異常検出ルールを設定
  processor.add_rule(:high_value, threshold: 100)
  processor.add_rule(:rapid_change, change_rate: 0.5)
  processor.add_rule(:statistical_outlier, z_score: 3)

  puts '=== Simulating Data Stream ==='

  # 正常なデータ
  20.times do |_i|
    value = 25 + rand(-5.0..5.0)
    processor.process(DataPoint.new(value: value))
  end

  # 異常値を挿入
  processor.process(DataPoint.new(value: 150)) # 高い値

  # 通常のデータ
  10.times do |_i|
    value = 25 + rand(-5.0..5.0)
    processor.process(DataPoint.new(value: value))
  end

  # 急激な変化
  processor.process(DataPoint.new(value: 80))

  # 徐々に増加するトレンド
  10.times do |i|
    value = 30 + i * 2 + rand(-2.0..2.0)
    processor.process(DataPoint.new(value: value))
  end

  puts "\n=== Statistics ==="
  stats = processor.get_statistics
  stats.each { |k, v| puts "#{k}: #{v}" }

  puts "\n=== Trend Analysis ==="
  puts "Current trend: #{processor.get_trend}"

  puts "\n=== Alerts ==="
  alerts = processor.get_alerts
  if alerts.empty?
    puts 'No alerts'
  else
    alerts.each do |alert|
      puts "#{alert[:timestamp].strftime('%H:%M:%S')} - #{alert[:type]}: #{alert[:message]}"
    end
  end

  # パフォーマンステスト
  puts "\n=== Performance Test ==="
  require 'benchmark'

  test_processor = StreamProcessor.new(window_size: 1000)

  time = Benchmark.realtime do
    10_000.times do
      value = 50 + rand(-20.0..20.0)
      test_processor.process(DataPoint.new(value: value))
    end
  end

  puts "Processed 10,000 data points in #{(time * 1000).round(2)}ms"
  puts "Average: #{(time * 1_000_000 / 10_000).round(2)}μs per data point"
end
