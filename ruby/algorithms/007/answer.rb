require 'time'

class LogEntry
  include Comparable

  attr_reader :message, :level, :source, :timestamp, :priority

  LEVEL_PRIORITY = { error: 0, warn: 1, info: 2 }

  def initialize(message, level, source)
    @message = message
    @level = level
    @source = source
    @timestamp = Time.now
    @priority = LEVEL_PRIORITY[level] || 999
  end

  def <=>(other)
    # 優先度が高い（数値が小さい）順、同じなら時刻順
    comp = @priority <=> other.priority
    comp == 0 ? @timestamp <=> other.timestamp : comp
  end

  def to_s
    "[#{@timestamp.strftime('%Y-%m-%d %H:%M:%S.%L')}] [#{@level.to_s.upcase}] [#{@source}] #{@message}"
  end
end

class LogQueue
  def initialize(max_size)
    @max_size = max_size
    @queue = []
    @mutex = Mutex.new
    @not_empty = ConditionVariable.new
    @not_full = ConditionVariable.new
    @closed = false
  end

  def push(log_entry)
    @mutex.synchronize do
      # キューが満杯の場合は待機
      @not_full.wait(@mutex) while @queue.size >= @max_size && !@closed

      return false if @closed

      # 優先度を考慮して適切な位置に挿入
      insert_position = @queue.bsearch_index { |entry| entry >= log_entry } || @queue.size
      @queue.insert(insert_position, log_entry)

      @not_empty.signal
      true
    end
  end

  def pop_batch(batch_size)
    @mutex.synchronize do
      # キューが空の場合は待機
      @not_empty.wait(@mutex) while @queue.empty? && !@closed

      return [] if @queue.empty? && @closed

      # バッチサイズ分取り出し
      batch = []
      [batch_size, @queue.size].min.times do
        batch << @queue.shift
      end

      @not_full.broadcast if @queue.size < @max_size
      batch
    end
  end

  def size
    @mutex.synchronize { @queue.size }
  end

  def close
    @mutex.synchronize do
      @closed = true
      @not_empty.broadcast
      @not_full.broadcast
    end
  end

  def closed?
    @mutex.synchronize { @closed }
  end
end

class LogProcessor
  def initialize(batch_size: 10, max_queue_size: 100)
    @batch_size = batch_size
    @queue = LogQueue.new(max_queue_size)
    @processing_thread = nil
    @stats = {
      processed: 0,
      batches: 0,
      total_process_time: 0,
      dropped: 0
    }
    @stats_mutex = Mutex.new
    @running = false
  end

  def add_log(message, level, source)
    log_entry = LogEntry.new(message, level, source)

    if @queue.push(log_entry)
      true
    else
      @stats_mutex.synchronize { @stats[:dropped] += 1 }
      false
    end
  end

  def start_processing
    return if @running

    @running = true
    @processing_thread = Thread.new do
      while @running || @queue.size > 0
        batch = @queue.pop_batch(@batch_size)
        break if batch.empty? && !@running

        process_batch(batch) unless batch.empty?
      end
    end
  end

  def stop_processing
    @running = false
    @queue.close
    @processing_thread.join if @processing_thread
  end

  def get_stats
    @stats_mutex.synchronize do
      avg_batch_size = if @stats[:batches] > 0
                         @stats[:processed].to_f / @stats[:batches]
                       else
                         0
                       end

      avg_process_time = if @stats[:batches] > 0
                           @stats[:total_process_time] / @stats[:batches]
                         else
                           0
                         end

      {
        processed: @stats[:processed],
        dropped: @stats[:dropped],
        batches: @stats[:batches],
        avg_batch_size: avg_batch_size.round(2),
        avg_process_time: avg_process_time.round(4),
        queue_size: @queue.size
      }
    end
  end

  private

  def process_batch(batch)
    start_time = Time.now

    # バッチ処理のシミュレーション
    batch.each do |log_entry|
      # 実際の処理（ファイル書き込み、データベース保存など）
      puts log_entry if log_entry.level == :error # エラーログは即座に出力
    end

    # 処理時間のシミュレーション
    sleep(0.001 * batch.size)

    process_time = Time.now - start_time

    @stats_mutex.synchronize do
      @stats[:processed] += batch.size
      @stats[:batches] += 1
      @stats[:total_process_time] += process_time
    end
  end
end

# テスト
if __FILE__ == $0
  processor = LogProcessor.new(batch_size: 5, max_queue_size: 50)

  # ログ処理を開始
  processor.start_processing

  # 複数のプロデューサーを起動
  producers = []

  # エラーログプロデューサー
  producers << Thread.new do
    5.times do |i|
      processor.add_log("Critical error #{i}", :error, 'Service A')
      sleep(0.02)
    end
  end

  # 警告ログプロデューサー
  producers << Thread.new do
    10.times do |i|
      processor.add_log("Warning: high memory usage #{i}", :warn, 'Service B')
      sleep(0.01)
    end
  end

  # 情報ログプロデューサー
  producers << Thread.new do
    20.times do |i|
      processor.add_log("Request processed #{i}", :info, 'Service C')
      sleep(0.005)
    end
  end

  # 高頻度プロデューサー（バックプレッシャーテスト）
  producers << Thread.new do
    30.times do |i|
      puts 'Log dropped due to backpressure!' unless processor.add_log("Rapid log #{i}", :info, 'Service D')
      sleep(0.001)
    end
  end

  # プロデューサーの完了を待つ
  producers.each(&:join)

  # 少し待ってから処理を停止
  sleep(0.5)
  processor.stop_processing

  # 統計情報を表示
  puts "\n=== Processing Statistics ==="
  stats = processor.get_stats
  puts "Total processed: #{stats[:processed]} logs"
  puts "Total dropped: #{stats[:dropped]} logs"
  puts "Total batches: #{stats[:batches]}"
  puts "Average batch size: #{stats[:avg_batch_size]}"
  puts "Average process time: #{stats[:avg_process_time]}s per batch"
  puts "Final queue size: #{stats[:queue_size]}"
end
