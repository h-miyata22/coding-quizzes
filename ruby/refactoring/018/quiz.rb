class MetricsCollector
  def collect_and_report(service_name, metric_type)
    # メトリクス収集
    if metric_type == 'performance'
      start_time = Time.now
      cpu_before = get_cpu_usage
      memory_before = get_memory_usage

      # サービス実行
      result = nil
      case service_name
      when 'api'
        result = call_api_service
      when 'database'
        result = call_database_service
      when 'cache'
        result = call_cache_service
      else
        return nil
      end

      end_time = Time.now
      cpu_after = get_cpu_usage
      memory_after = get_memory_usage

      # レポート生成
      report = ''
      report += "Performance Report for #{service_name}\n"
      report += "=====================================\n"
      report += "Execution Time: #{end_time - start_time} seconds\n"
      report += "CPU Usage: #{cpu_after - cpu_before}%\n"
      report += "Memory Usage: #{memory_after - memory_before} MB\n"
      report += "Result: #{result}\n"

      # ログ出力
      File.open('metrics.log', 'a') do |f|
        f.puts "[#{Time.now}] #{report}"
      end

      # メール通知
      send_email('admin@example.com', 'Performance Alert', report) if end_time - start_time > 5.0

      report

    elsif metric_type == 'availability'
      success_count = 0
      total_count = 10

      # 可用性チェック
      for i in 0..total_count - 1
        case service_name
        when 'api'
          success_count += 1 if check_api_health
        when 'database'
          success_count += 1 if check_database_health
        when 'cache'
          success_count += 1 if check_cache_health
        end

        sleep(1)
      end

      availability = (success_count.to_f / total_count) * 100

      # レポート生成
      report = ''
      report += "Availability Report for #{service_name}\n"
      report += "=====================================\n"
      report += "Success Rate: #{availability}%\n"
      report += "Failed Checks: #{total_count - success_count}\n"

      # ログ出力
      File.open('metrics.log', 'a') do |f|
        f.puts "[#{Time.now}] #{report}"
      end

      # メール通知
      send_email('admin@example.com', 'Availability Alert', report) if availability < 90.0

      report

    elsif metric_type == 'error_rate'
      errors = []

      # エラー収集
      case service_name
      when 'api'
        errors = get_api_errors
      when 'database'
        errors = get_database_errors
      when 'cache'
        errors = get_cache_errors
      end

      error_count = errors.length
      error_types = {}

      # エラー分類
      for i in 0..errors.length - 1
        error = errors[i]
        type = error[:type] || 'Unknown'
        if error_types[type]
          error_types[type] += 1
        else
          error_types[type] = 1
        end
      end

      # レポート生成
      report = ''
      report += "Error Report for #{service_name}\n"
      report += "=====================================\n"
      report += "Total Errors: #{error_count}\n"
      report += "Error Types:\n"

      error_types.each do |type, count|
        report += "  #{type}: #{count}\n"
      end

      # ログ出力
      File.open('metrics.log', 'a') do |f|
        f.puts "[#{Time.now}] #{report}"
      end

      # メール通知
      send_email('admin@example.com', 'Error Alert', report) if error_count > 10

      report
    end
  end

  private

  def get_cpu_usage
    # CPUダミー実装
    rand(0..100)
  end

  def get_memory_usage
    # メモリダミー実装
    rand(100..1000)
  end

  def call_api_service
    # APIサービスダミー実装
    'API Response'
  end

  def call_database_service
    # DBサービスダミー実装
    'DB Response'
  end

  def call_cache_service
    # キャッシュサービスダミー実装
    'Cache Response'
  end

  def check_api_health
    # APIヘルスチェックダミー実装
    rand > 0.1
  end

  def check_database_health
    # DBヘルスチェックダミー実装
    rand > 0.1
  end

  def check_cache_health
    # キャッシュヘルスチェックダミー実装
    rand > 0.1
  end

  def get_api_errors
    # APIエラー取得ダミー実装
    [{ type: 'Timeout', message: 'Request timeout' }, { type: 'NotFound', message: 'Not found' }]
  end

  def get_database_errors
    # DBエラー取得ダミー実装
    [{ type: 'ConnectionError', message: 'Connection failed' }]
  end

  def get_cache_errors
    # キャッシュエラー取得ダミー実装
    []
  end

  def send_email(to, subject, body)
    # メール送信ダミー実装
    puts "Email sent to #{to}: #{subject}"
  end
end
