require 'time'

class AccessLog
  attr_reader :ip, :timestamp, :method, :path, :status, :size, :user_agent, :raw

  def initialize(ip:, timestamp:, method:, path:, status:, size:, raw:, user_agent: nil)
    @ip = ip
    @timestamp = timestamp
    @method = method
    @path = path
    @status = status.to_i
    @size = size.to_i
    @user_agent = user_agent
    @raw = raw
  end

  def success?
    @status >= 200 && @status < 300
  end

  def error?
    @status >= 400
  end

  def hour
    @timestamp.hour
  end

  def date
    @timestamp.to_date
  end
end

class LogParser
  # 一般的なログフォーマットの正規表現
  FORMATS = {
    apache_common: /^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) \S+" (\d+) (\d+|-)$/,
    apache_combined: /^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) \S+" (\d+) (\d+|-) "([^"]*)" "([^"]*)"$/,
    nginx: /^(\S+) - - \[([^\]]+)\] "(\S+) (\S+) \S+" (\d+) (\d+) "([^"]*)" "([^"]*)"$/,
    custom: /^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(\S+)\] (\S+) (\S+) (\d+) (\d+)$/
  }

  def self.parse(log_line)
    # 各フォーマットを試す
    FORMATS.each do |format_name, regex|
      match = log_line.match(regex)
      next unless match

      case format_name
      when :apache_common, :apache_combined, :nginx
        return parse_standard_format(match, log_line, format_name)
      when :custom
        return parse_custom_format(match, log_line)
      end
    end

    # どのフォーマットにも一致しない場合
    nil
  end

  def self.parse_standard_format(match, raw_log, format_name)
    ip = match[1]
    timestamp = parse_timestamp(match[2])
    method = match[3]
    path = match[4]
    status = match[5]
    size = match[6] == '-' ? 0 : match[6]

    user_agent = nil
    user_agent = match[8] if %i[apache_combined nginx].include?(format_name)

    AccessLog.new(
      ip: ip,
      timestamp: timestamp,
      method: method,
      path: path,
      status: status,
      size: size,
      user_agent: user_agent,
      raw: raw_log
    )
  end

  def self.parse_custom_format(match, raw_log)
    timestamp = Time.parse(match[1])
    ip = match[2]
    method = match[3]
    path = match[4]
    status = match[5]
    size = match[6]

    AccessLog.new(
      ip: ip,
      timestamp: timestamp,
      method: method,
      path: path,
      status: status,
      size: size,
      raw: raw_log
    )
  end

  def self.parse_timestamp(timestamp_str)
    # Apache/Nginxのタイムスタンプフォーマット: 10/Oct/2024:13:55:36 +0900
    Time.strptime(timestamp_str, '%d/%b/%Y:%H:%M:%S %z')
  rescue StandardError
    Time.parse(timestamp_str)
  end
end

class LogAnalyzer
  def initialize
    @logs = []
    @ip_access_times = Hash.new { |h, k| h[k] = [] }
  end

  def add_log(log_line)
    parsed = LogParser.parse(log_line)
    return false unless parsed

    @logs << parsed
    @ip_access_times[parsed.ip] << parsed.timestamp
    true
  end

  def generate_stats
    return {} if @logs.empty?

    {
      total: @logs.size,
      by_status: group_by_status,
      by_method: group_by_method,
      by_hour: group_by_hour,
      by_ip: top_ips(10),
      error_rate: calculate_error_rate,
      avg_response_size: calculate_avg_size,
      popular_paths: popular_paths(10)
    }
  end

  def detect_anomalies(threshold: 10, time_window: 60)
    anomalies = []

    # 高頻度アクセスの検出
    @ip_access_times.each do |ip, timestamps|
      if timestamps.size > threshold
        anomalies << {
          ip: ip,
          count: timestamps.size,
          type: :high_frequency
        }
      end

      # 短時間での大量アクセス
      rapid_accesses = count_rapid_accesses(timestamps, time_window)
      next unless rapid_accesses > threshold

      anomalies << {
        ip: ip,
        count: rapid_accesses,
        type: :rapid_access,
        time_window: time_window
      }
    end

    # 異常なステータスコードパターン
    error_ips = detect_error_patterns
    error_ips.each do |ip, error_count|
      next unless error_count > threshold / 2

      anomalies << {
        ip: ip,
        count: error_count,
        type: :high_error_rate
      }
    end

    anomalies.uniq { |a| [a[:ip], a[:type]] }
  end

  def filter_logs(&block)
    @logs.select(&block)
  end

  def search(criteria = {})
    results = @logs

    results = results.select { |log| log.ip == criteria[:ip] } if criteria[:ip]
    results = results.select { |log| log.method == criteria[:method] } if criteria[:method]
    results = results.select { |log| log.path.include?(criteria[:path]) } if criteria[:path]
    results = results.select { |log| log.status == criteria[:status] } if criteria[:status]

    if criteria[:time_range]
      start_time, end_time = criteria[:time_range]
      results = results.select { |log| log.timestamp >= start_time && log.timestamp <= end_time }
    end

    results
  end

  def generate_report
    stats = generate_stats
    anomalies = detect_anomalies

    report = []
    report << '=== Web Access Log Analysis Report ==='
    report << "Generated at: #{Time.now}"
    report << ''
    report << "Total Requests: #{stats[:total]}"
    report << "Error Rate: #{format('%.2f', stats[:error_rate] * 100)}%"
    report << "Average Response Size: #{stats[:avg_response_size]} bytes"
    report << ''
    report << 'Status Code Distribution:'
    stats[:by_status].each { |status, count| report << "  #{status}: #{count}" }
    report << ''
    report << 'HTTP Method Distribution:'
    stats[:by_method].each { |method, count| report << "  #{method}: #{count}" }
    report << ''
    report << 'Top 10 IP Addresses:'
    stats[:by_ip].each { |ip, count| report << "  #{ip}: #{count} requests" }
    report << ''
    report << 'Popular Paths:'
    stats[:popular_paths].each { |path, count| report << "  #{path}: #{count} requests" }

    if anomalies.any?
      report << ''
      report << 'Detected Anomalies:'
      anomalies.each do |anomaly|
        report << "  IP: #{anomaly[:ip]}, Type: #{anomaly[:type]}, Count: #{anomaly[:count]}"
      end
    end

    report.join("\n")
  end

  private

  def group_by_status
    @logs.group_by(&:status).transform_values(&:size)
  end

  def group_by_method
    @logs.group_by(&:method).transform_values(&:size)
  end

  def group_by_hour
    @logs.group_by(&:hour).transform_values(&:size).sort.to_h
  end

  def top_ips(limit)
    @logs.group_by(&:ip)
         .transform_values(&:size)
         .sort_by { |_, count| -count }
         .first(limit)
         .to_h
  end

  def popular_paths(limit)
    @logs.group_by(&:path)
         .transform_values(&:size)
         .sort_by { |_, count| -count }
         .first(limit)
         .to_h
  end

  def calculate_error_rate
    error_count = @logs.count(&:error?)
    error_count.to_f / @logs.size
  end

  def calculate_avg_size
    total_size = @logs.sum(&:size)
    total_size / @logs.size
  end

  def count_rapid_accesses(timestamps, window_seconds)
    return 0 if timestamps.size < 2

    sorted_times = timestamps.sort
    max_count = 0

    sorted_times.each_with_index do |start_time, i|
      count = 1
      (i + 1...sorted_times.size).each do |j|
        break unless sorted_times[j] - start_time <= window_seconds

        count += 1
      end
      max_count = [max_count, count].max
    end

    max_count
  end

  def detect_error_patterns
    error_counts = Hash.new(0)

    @logs.each do |log|
      error_counts[log.ip] += 1 if log.error?
    end

    error_counts
  end
end

# テスト
if __FILE__ == $0
  analyzer = LogAnalyzer.new

  # サンプルログ
  logs = [
    '192.168.1.1 - - [10/Oct/2024:13:55:36 +0900] "GET /index.html HTTP/1.1" 200 2326',
    '192.168.1.2 - - [10/Oct/2024:13:56:12 +0900] "POST /api/users HTTP/1.1" 201 156',
    '192.168.1.1 - - [10/Oct/2024:13:56:45 +0900] "GET /favicon.ico HTTP/1.1" 404 209',
    '192.168.1.3 - - [10/Oct/2024:13:57:01 +0900] "GET /api/products HTTP/1.1" 200 5432',
    '192.168.1.1 - - [10/Oct/2024:13:57:15 +0900] "GET /images/logo.png HTTP/1.1" 200 8765',
    '192.168.1.2 - - [10/Oct/2024:13:57:30 +0900] "DELETE /api/users/123 HTTP/1.1" 403 87',
    '192.168.1.4 - - [10/Oct/2024:13:58:00 +0900] "GET /admin HTTP/1.1" 401 112',
    '192.168.1.1 - - [10/Oct/2024:13:58:10 +0900] "GET /api/users HTTP/1.1" 500 256'
  ]

  # ログを追加
  logs.each { |log| analyzer.add_log(log) }

  # レポート生成
  puts analyzer.generate_report

  # 特定条件での検索
  puts "\n=== Search Results (Status 404) ==="
  results = analyzer.search(status: 404)
  results.each { |log| puts log.raw }

  # カスタムフィルタ
  puts "\n=== API Endpoints ==="
  api_logs = analyzer.filter_logs { |log| log.path.start_with?('/api/') }
  api_logs.each { |log| puts "#{log.method} #{log.path} - #{log.status}" }
end
