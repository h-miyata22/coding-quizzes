class MetricsCollector
  def initialize(logger: FileLogger.new, notifier: EmailNotifier.new)
    @logger = logger
    @notifier = notifier
  end

  def collect_and_report(service_name, metric_type)
    service = ServiceFactory.create(service_name)
    return nil unless service

    collector = MetricCollectorFactory.create(metric_type, service)
    return nil unless collector

    report = collector.collect
    @logger.log(report)
    @notifier.notify_if_needed(report)

    report.to_s
  end
end

class ServiceFactory
  SERVICES = {
    api: ApiService,
    database: DatabaseService,
    cache: CacheService
  }.freeze

  def self.create(name)
    service_class = SERVICES[name.to_sym]
    service_class&.new
  end
end

class MetricCollectorFactory
  COLLECTORS = {
    performance: PerformanceCollector,
    availability: AvailabilityCollector,
    error_rate: ErrorRateCollector
  }.freeze

  def self.create(type, service)
    collector_class = COLLECTORS[type.to_sym]
    collector_class&.new(service)
  end
end

class Service
  def execute
    raise NotImplementedError
  end

  def check_health
    raise NotImplementedError
  end

  def get_errors
    raise NotImplementedError
  end
end

class ApiService < Service
  def execute
    'API Response'
  end

  def check_health
    rand > 0.1
  end

  def get_errors
    ErrorCollection.new([
                          ServiceError.new('Timeout', 'Request timeout'),
                          ServiceError.new('NotFound', 'Not found')
                        ])
  end
end

class DatabaseService < Service
  def execute
    'DB Response'
  end

  def check_health
    rand > 0.1
  end

  def get_errors
    ErrorCollection.new([
                          ServiceError.new('ConnectionError', 'Connection failed')
                        ])
  end
end

class CacheService < Service
  def execute
    'Cache Response'
  end

  def check_health
    rand > 0.1
  end

  def get_errors
    ErrorCollection.new
  end
end

class MetricCollector
  def initialize(service)
    @service = service
  end

  def collect
    raise NotImplementedError
  end
end

class PerformanceCollector < MetricCollector
  ALERT_THRESHOLD_SECONDS = 5.0

  def collect
    metrics = PerformanceMetrics.new

    metrics.measure do
      @service.execute
    end

    Report.new(
      title: "Performance Report for #{@service.class.name.sub('Service', '').downcase}",
      metrics: metrics.to_h,
      alert_condition: metrics.execution_time > ALERT_THRESHOLD_SECONDS,
      alert_type: 'Performance Alert'
    )
  end
end

class AvailabilityCollector < MetricCollector
  CHECK_COUNT = 10
  CHECK_INTERVAL = 1
  ALERT_THRESHOLD_PERCENT = 90.0

  def collect
    checker = AvailabilityChecker.new(@service)
    availability = checker.check(CHECK_COUNT, CHECK_INTERVAL)

    Report.new(
      title: "Availability Report for #{@service.class.name.sub('Service', '').downcase}",
      metrics: {
        'Success Rate' => "#{availability.success_rate}%",
        'Failed Checks' => availability.failed_count
      },
      alert_condition: availability.success_rate < ALERT_THRESHOLD_PERCENT,
      alert_type: 'Availability Alert'
    )
  end
end

class ErrorRateCollector < MetricCollector
  ALERT_THRESHOLD_COUNT = 10

  def collect
    errors = @service.get_errors

    Report.new(
      title: "Error Report for #{@service.class.name.sub('Service', '').downcase}",
      metrics: build_error_metrics(errors),
      alert_condition: errors.count > ALERT_THRESHOLD_COUNT,
      alert_type: 'Error Alert'
    )
  end

  private

  def build_error_metrics(errors)
    {
      'Total Errors' => errors.count,
      'Error Types' => errors.group_by_type
    }
  end
end

class PerformanceMetrics
  attr_reader :execution_time, :cpu_delta, :memory_delta

  def measure
    start_metrics = capture_system_metrics
    start_time = Time.now

    result = yield

    end_time = Time.now
    end_metrics = capture_system_metrics

    @execution_time = end_time - start_time
    @cpu_delta = end_metrics[:cpu] - start_metrics[:cpu]
    @memory_delta = end_metrics[:memory] - start_metrics[:memory]

    result
  end

  def to_h
    {
      'Execution Time' => "#{execution_time} seconds",
      'CPU Usage' => "#{cpu_delta}%",
      'Memory Usage' => "#{memory_delta} MB"
    }
  end

  private

  def capture_system_metrics
    {
      cpu: rand(0..100),
      memory: rand(100..1000)
    }
  end
end

class AvailabilityChecker
  def initialize(service)
    @service = service
  end

  def check(count, interval)
    results = count.times.map do
      success = @service.check_health
      sleep(interval)
      success
    end

    AvailabilityResult.new(results)
  end
end

class AvailabilityResult
  def initialize(results)
    @results = results
  end

  def success_rate
    (success_count.to_f / @results.length) * 100
  end

  def failed_count
    @results.length - success_count
  end

  private

  def success_count
    @results.count(true)
  end
end

class ServiceError
  attr_reader :type, :message

  def initialize(type, message)
    @type = type
    @message = message
  end
end

class ErrorCollection
  def initialize(errors = [])
    @errors = errors
  end

  def count
    @errors.length
  end

  def group_by_type
    @errors.group_by(&:type).transform_values(&:count)
  end
end

class Report
  attr_reader :title, :metrics, :alert_condition, :alert_type

  def initialize(title:, metrics:, alert_condition:, alert_type:)
    @title = title
    @metrics = metrics
    @alert_condition = alert_condition
    @alert_type = alert_type
  end

  def to_s
    ReportFormatter.new(self).format
  end
end

class ReportFormatter
  SEPARATOR = '=' * 37

  def initialize(report)
    @report = report
  end

  def format
    lines = []
    lines << @report.title
    lines << SEPARATOR

    @report.metrics.each do |key, value|
      lines << format_metric(key, value)
    end

    lines.join("\n")
  end

  private

  def format_metric(key, value)
    if value.is_a?(Hash)
      lines = ["#{key}:"]
      value.each do |sub_key, sub_value|
        lines << "  #{sub_key}: #{sub_value}"
      end
      lines.join("\n")
    else
      "#{key}: #{value}"
    end
  end
end

class FileLogger
  DEFAULT_FILE = 'metrics.log'

  def initialize(file_path: DEFAULT_FILE)
    @file_path = file_path
  end

  def log(report)
    File.open(@file_path, 'a') do |f|
      f.puts "[#{Time.now}] #{report}"
    end
  end
end

class EmailNotifier
  DEFAULT_RECIPIENT = 'admin@example.com'

  def initialize(recipient: DEFAULT_RECIPIENT)
    @recipient = recipient
  end

  def notify_if_needed(report)
    return unless report.alert_condition

    send_email(@recipient, report.alert_type, report.to_s)
  end

  private

  def send_email(to, subject, _body)
    puts "Email sent to #{to}: #{subject}"
  end
end
