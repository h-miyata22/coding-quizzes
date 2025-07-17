class TaskQueue
  def initialize
    @queue = PriorityQueue.new
    @registry = TaskRegistry.new
    @executor = TaskExecutor.new(@registry)
    @status_tracker = StatusTracker.new
  end

  def add_task(type, data, priority: 5, retry_count: 3)
    task = Task.create(
      type: type,
      data: data,
      priority: Priority.new(priority),
      retry_policy: RetryPolicy.new(max_attempts: retry_count)
    )

    @queue.enqueue(task)
    @status_tracker.track(task)

    task.id
  end

  def process_tasks
    processor = QueueProcessor.new(
      queue: @queue,
      executor: @executor,
      status_tracker: @status_tracker
    )

    processor.start
  end

  def stop
    @executor.stop
  end

  def get_status
    @status_tracker.summary
  end

  def get_task_info(task_id)
    @status_tracker.find_task(task_id)&.to_info
  end
end

class Task
  attr_reader :id, :type, :data, :priority, :retry_policy
  attr_accessor :state, :result, :error, :attempts

  def self.create(type:, data:, priority:, retry_policy:)
    new(
      id: generate_id,
      type: type,
      data: data,
      priority: priority,
      retry_policy: retry_policy,
      state: PendingState.new
    )
  end

  def initialize(id:, type:, data:, priority:, retry_policy:, state:)
    @id = id
    @type = type
    @data = data
    @priority = priority
    @retry_policy = retry_policy
    @state = state
    @attempts = 0
    @created_at = Time.now
  end

  def execute(handler)
    @state.execute(self, handler)
  end

  def transition_to(new_state)
    @state = new_state
    @state.on_enter(self)
  end

  def can_retry?
    @retry_policy.can_retry?(@attempts)
  end

  def increment_attempts
    @attempts += 1
  end

  def to_info
    TaskInfo.new(
      id: @id,
      type: @type,
      status: @state.status,
      attempts: @attempts,
      created_at: @created_at,
      duration: calculate_duration,
      error: @error&.message
    )
  end

  private

  def self.generate_id
    "task_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
  end

  def calculate_duration
    return nil unless @started_at && @completed_at

    @completed_at - @started_at
  end
end

class TaskState
  def execute(task, handler)
    raise NotImplementedError
  end

  def status
    self.class.name.sub('State', '').downcase
  end

  def on_enter(task)
    # Hook for state entry actions
  end
end

class PendingState < TaskState
  def execute(task, handler)
    task.transition_to(RunningState.new)

    begin
      result = handler.handle(task)
      task.result = result
      task.transition_to(CompletedState.new)

      notify_success(task, result)
    rescue StandardError => e
      task.error = e
      task.increment_attempts

      if task.can_retry?
        task.transition_to(RetryingState.new)
      else
        task.transition_to(FailedState.new)
        notify_failure(task, e)
      end
    end
  end

  private

  def notify_success(task, result)
    callback = task.data[:on_success]
    callback&.call(result)
  end

  def notify_failure(task, error)
    callback = task.data[:on_failure]
    callback&.call(error.message)
  end
end

class RunningState < TaskState
  def on_enter(task)
    task.instance_variable_set(:@started_at, Time.now)
  end

  def execute(_task, _handler)
    # Already running, should not execute again
    raise 'Task is already running'
  end
end

class CompletedState < TaskState
  def on_enter(task)
    task.instance_variable_set(:@completed_at, Time.now)
  end

  def execute(task, _handler)
    # Already completed
    task
  end
end

class RetryingState < TaskState
  BACKOFF_MULTIPLIER = 5

  def on_enter(task)
    retry_delay = task.attempts * BACKOFF_MULTIPLIER
    task.instance_variable_set(:@retry_after, Time.now + retry_delay)
  end

  def execute(task, handler)
    return unless Time.now >= task.instance_variable_get(:@retry_after)

    task.transition_to(PendingState.new)
    task.execute(handler)
  end

  def status
    'pending' # Show as pending in status
  end
end

class FailedState < TaskState
  def on_enter(task)
    task.instance_variable_set(:@failed_at, Time.now)
  end

  def execute(task, _handler)
    # Already failed
    task
  end
end

class Priority
  include Comparable

  attr_reader :value

  def initialize(value)
    raise ArgumentError, 'Priority must be between 1 and 10' unless (1..10).include?(value)

    @value = value
  end

  def <=>(other)
    other.value <=> @value # Higher priority first
  end
end

class RetryPolicy
  def initialize(max_attempts:)
    @max_attempts = max_attempts
  end

  def can_retry?(current_attempts)
    current_attempts < @max_attempts
  end
end

class PriorityQueue
  def initialize
    @tasks = []
    @mutex = Mutex.new
  end

  def enqueue(task)
    @mutex.synchronize do
      insert_position = @tasks.bsearch_index { |t| task.priority >= t.priority } || @tasks.length
      @tasks.insert(insert_position, task)
    end
  end

  def dequeue
    @mutex.synchronize do
      @tasks.shift
    end
  end

  def empty?
    @tasks.empty?
  end
end

class TaskHandler
  def handle(task)
    raise NotImplementedError
  end
end

class EmailHandler < TaskHandler
  def handle(task)
    data = task.data
    validate_email(data[:to])

    puts "Sending email to #{data[:to]}"
    sleep(1)  # Simulate sending time

    'Email sent'
  end

  private

  def validate_email(email)
    raise 'Invalid email address' if email.nil? || email.empty?
  end
end

class HttpRequestHandler < TaskHandler
  def handle(task)
    data = task.data
    validate_url(data[:url])

    puts "Making HTTP request to #{data[:url]}"
    sleep(2)  # Simulate request time

    'Response: 200 OK'
  end

  private

  def validate_url(url)
    raise 'Invalid URL' unless url&.start_with?('http')
  end
end

class DataProcessingHandler < TaskHandler
  def handle(task)
    data = task.data
    validate_input(data[:input])

    puts "Processing data: #{data[:input]}"
    processed = data[:input].upcase
    sleep(0.5)

    "Processed: #{processed}"
  end

  private

  def validate_input(input)
    raise 'No input data' if input.nil?
  end
end

class ReportGenerationHandler < TaskHandler
  VALID_REPORT_TYPES = %w[daily weekly monthly].freeze

  def handle(task)
    data = task.data
    validate_report_type(data[:report_type])

    puts "Generating report: #{data[:report_type]}"
    sleep(3)  # Simulate generation time

    "Report generated: #{data[:report_type]}_report.pdf"
  end

  private

  def validate_report_type(type)
    raise 'Invalid report type' unless VALID_REPORT_TYPES.include?(type)
  end
end

class TaskRegistry
  def initialize
    @handlers = {
      'email' => EmailHandler.new,
      'http_request' => HttpRequestHandler.new,
      'data_processing' => DataProcessingHandler.new,
      'report_generation' => ReportGenerationHandler.new
    }
  end

  def get_handler(type)
    @handlers[type] || raise("Unknown task type: #{type}")
  end
end

class TaskExecutor
  def initialize(registry)
    @registry = registry
    @running = true
    @rate_limiter = RateLimiter.new(delay: 0.1)
  end

  def execute(task)
    handler = @registry.get_handler(task.type)

    @rate_limiter.throttle do
      task.execute(handler)
    end
  end

  def stop
    @running = false
  end

  def running?
    @running
  end
end

class RateLimiter
  def initialize(delay:)
    @delay = delay
    @last_execution = Time.now - delay
  end

  def throttle
    time_since_last = Time.now - @last_execution
    sleep_time = @delay - time_since_last

    sleep(sleep_time) if sleep_time > 0

    result = yield
    @last_execution = Time.now
    result
  end
end

class QueueProcessor
  def initialize(queue:, executor:, status_tracker:)
    @queue = queue
    @executor = executor
    @status_tracker = status_tracker
  end

  def start
    while @executor.running? && !@queue.empty?
      task = @queue.dequeue
      @executor.execute(task)
      @status_tracker.update(task)
    end
  end
end

class StatusTracker
  def initialize
    @tasks = []
    @mutex = Mutex.new
  end

  def track(task)
    @mutex.synchronize do
      @tasks << task
    end
  end

  def update(task)
    # Task is already tracked, just need to ensure thread safety
  end

  def find_task(task_id)
    @mutex.synchronize do
      @tasks.find { |t| t.id == task_id }
    end
  end

  def summary
    @mutex.synchronize do
      StatusSummary.new(
        pending: count_by_status('pending'),
        completed: count_by_status('completed'),
        failed: count_by_status('failed')
      )
    end
  end

  private

  def count_by_status(status)
    @tasks.count { |t| t.state.status == status }
  end
end

class StatusSummary
  attr_reader :pending, :completed, :failed

  def initialize(pending:, completed:, failed:)
    @pending = pending
    @completed = completed
    @failed = failed
  end

  def total
    @pending + @completed + @failed
  end

  def to_h
    {
      pending: @pending,
      completed: @completed,
      failed: @failed,
      total: total
    }
  end
end

class TaskInfo
  def initialize(id:, type:, status:, attempts:, created_at:, duration:, error:)
    @id = id
    @type = type
    @status = status
    @attempts = attempts
    @created_at = created_at
    @duration = duration
    @error = error
  end

  def to_h
    {
      id: @id,
      type: @type,
      status: @status,
      attempts: @attempts,
      created_at: @created_at,
      duration: @duration,
      error: @error
    }.compact
  end
end
