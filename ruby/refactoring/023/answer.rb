class MessageQueue
  def initialize
    @topic_registry = TopicRegistry.new
    @subscription_manager = SubscriptionManager.new
    @message_store = MessageStore.new
    @delivery_service = DeliveryService.new
    @dead_letter_queue = DeadLetterQueue.new
  end

  def create_topic(topic_name, max_retries: 3, retention_period: 86_400)
    topic = Topic.new(
      name: topic_name,
      max_retries: max_retries,
      retention_policy: RetentionPolicy.new(period: retention_period)
    )

    @topic_registry.register(topic)
  end

  def subscribe(topic_name, subscriber_name, filter: nil, &handler)
    topic = @topic_registry.find(topic_name)
    return SubscriptionResult.failure('Topic not found') unless topic

    subscriber = Subscriber.new(
      name: subscriber_name,
      handler: MessageHandler.new(&handler),
      filter: MessageFilter.create(filter)
    )

    @subscription_manager.subscribe(topic, subscriber)
  end

  def publish(topic_name, content, priority: 5, attributes: {}, async: false)
    topic = @topic_registry.find(topic_name)
    return PublishResult.failure('Topic not found') unless topic

    message = Message.create(
      topic: topic,
      content: content,
      priority: Priority.new(priority),
      attributes: MessageAttributes.new(attributes)
    )

    @message_store.store(topic, message)

    delivery_strategy = async ? AsyncDeliveryStrategy.new : SyncDeliveryStrategy.new

    delivery_result = @delivery_service.deliver(
      message: message,
      subscribers: @subscription_manager.get_subscribers(topic),
      strategy: delivery_strategy,
      dead_letter_queue: @dead_letter_queue
    )

    PublishResult.success(
      message_id: message.id,
      delivered_count: delivery_result.delivered_count
    )
  end

  def get_messages(topic_name, subscriber_name, limit: 10)
    topic = @topic_registry.find(topic_name)
    return [] unless topic

    subscriber = @subscription_manager.find_subscriber(topic, subscriber_name)
    return [] unless subscriber

    messages = @message_store.get_messages(topic)
    filtered_messages = subscriber.filter.apply(messages)

    MessageQuery.new(filtered_messages)
                .order_by_newest
                .limit(limit)
                .execute
  end

  def unsubscribe(topic_name, subscriber_name)
    topic = @topic_registry.find(topic_name)
    return false unless topic

    @subscription_manager.unsubscribe(topic, subscriber_name)
  end

  def get_stats
    StatisticsCollector.new(
      topics: @topic_registry.all,
      message_store: @message_store,
      subscription_manager: @subscription_manager,
      dead_letter_queue: @dead_letter_queue
    ).collect
  end
end

class Topic
  attr_reader :name, :max_retries, :retention_policy

  def initialize(name:, max_retries:, retention_policy:)
    @name = name
    @max_retries = max_retries
    @retention_policy = retention_policy
    @created_at = Time.now
  end

  def ==(other)
    other.is_a?(Topic) && other.name == name
  end
end

class Message
  attr_reader :id, :topic, :content, :priority, :attributes, :published_at
  attr_accessor :retry_count

  def self.create(topic:, content:, priority:, attributes:)
    new(
      id: generate_id,
      topic: topic,
      content: content,
      priority: priority,
      attributes: attributes,
      published_at: Time.now
    )
  end

  def initialize(id:, topic:, content:, priority:, attributes:, published_at:)
    @id = id
    @topic = topic
    @content = content
    @priority = priority
    @attributes = attributes
    @published_at = published_at
    @retry_count = 0
  end

  def expired?(retention_policy)
    retention_policy.expired?(@published_at)
  end

  def increment_retry
    @retry_count += 1
  end

  def max_retries_exceeded?
    @retry_count >= @topic.max_retries
  end

  def self.generate_id
    "msg_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
  end
end

class Subscriber
  attr_reader :name, :handler, :filter

  def initialize(name:, handler:, filter:)
    @name = name
    @handler = handler
    @filter = filter
    @subscribed_at = Time.now
    @statistics = SubscriberStatistics.new
  end

  def handle(message)
    @handler.handle(message)
    @statistics.record_success
  end

  def record_error
    @statistics.record_error
  end

  def matches_message?(message)
    @filter.matches?(message)
  end

  def stats
    @statistics.summary
  end
end

class MessageHandler
  def initialize(&block)
    @handler = block
  end

  def handle(message)
    @handler.call(message.content, message.attributes.to_h)
  end
end

class MessageFilter
  def self.create(criteria)
    return NullFilter.new unless criteria

    AttributeFilter.new(criteria)
  end

  def matches?(message)
    raise NotImplementedError
  end

  def apply(messages)
    messages.select { |msg| matches?(msg) }
  end
end

class NullFilter < MessageFilter
  def matches?(_message)
    true
  end
end

class AttributeFilter < MessageFilter
  def initialize(criteria)
    @criteria = criteria
  end

  def matches?(message)
    @criteria.all? do |key, value|
      message.attributes.get(key) == value
    end
  end
end

class MessageAttributes
  def initialize(attributes = {})
    @attributes = attributes.freeze
  end

  def get(key)
    @attributes[key]
  end

  def to_h
    @attributes
  end
end

class Priority
  include Comparable

  MIN = 1
  MAX = 10

  attr_reader :value

  def initialize(value)
    @value = [[value, MIN].max, MAX].min
  end

  def <=>(other)
    @value <=> other.value
  end

  def delay_factor
    (MAX - @value) * 0.1
  end
end

class DeliveryService
  def deliver(message:, subscribers:, strategy:, dead_letter_queue:)
    result = DeliveryResult.new

    subscribers.each do |subscriber|
      next unless subscriber.matches_message?(message)

      delivery_context = DeliveryContext.new(
        message: message,
        subscriber: subscriber,
        dead_letter_queue: dead_letter_queue
      )

      if strategy.deliver(delivery_context)
        result.record_success
      else
        result.record_failure
      end
    end

    result
  end
end

class DeliveryStrategy
  def deliver(context)
    raise NotImplementedError
  end
end

class SyncDeliveryStrategy < DeliveryStrategy
  def deliver(context)
    DeliveryExecutor.new(context).execute
  end
end

class AsyncDeliveryStrategy < DeliveryStrategy
  def deliver(context)
    Thread.new do
      sleep(context.message.priority.delay_factor)
      DeliveryExecutor.new(context).execute
    end
    true
  end
end

class DeliveryExecutor
  def initialize(context)
    @context = context
  end

  def execute
    with_retry do
      @context.subscriber.handle(@context.message)
      true
    end
  rescue StandardError => e
    handle_failure(e)
    false
  end

  private

  def with_retry
    yield
  rescue StandardError => e
    raise unless should_retry?

    retry_delivery(e)
  end

  def should_retry?
    !@context.message.max_retries_exceeded?
  end

  def retry_delivery(error)
    @context.message.increment_retry

    Thread.new do
      sleep(@context.message.retry_count * 2)
      execute
    end

    raise error
  end

  def handle_failure(error)
    @context.subscriber.record_error

    return unless @context.message.max_retries_exceeded?

    @context.dead_letter_queue.add(
      message: @context.message,
      subscriber: @context.subscriber,
      error: error
    )
  end
end

class DeliveryContext
  attr_reader :message, :subscriber, :dead_letter_queue

  def initialize(message:, subscriber:, dead_letter_queue:)
    @message = message
    @subscriber = subscriber
    @dead_letter_queue = dead_letter_queue
  end
end

class DeliveryResult
  attr_reader :delivered_count, :failed_count

  def initialize
    @delivered_count = 0
    @failed_count = 0
  end

  def record_success
    @delivered_count += 1
  end

  def record_failure
    @failed_count += 1
  end
end

class TopicRegistry
  def initialize
    @topics = {}
    @mutex = Mutex.new
  end

  def register(topic)
    @mutex.synchronize do
      return false if @topics.key?(topic.name)

      @topics[topic.name] = topic
      true
    end
  end

  def find(name)
    @topics[name]
  end

  def all
    @topics.values
  end
end

class SubscriptionManager
  def initialize
    @subscriptions = Hash.new { |h, k| h[k] = [] }
    @mutex = Mutex.new
  end

  def subscribe(topic, subscriber)
    @mutex.synchronize do
      return SubscriptionResult.failure('Subscriber already exists') if subscriber_exists?(topic, subscriber.name)

      @subscriptions[topic] << subscriber
      SubscriptionResult.success
    end
  end

  def unsubscribe(topic, subscriber_name)
    @mutex.synchronize do
      @subscriptions[topic].delete_if { |s| s.name == subscriber_name }
    end
    true
  end

  def get_subscribers(topic)
    @subscriptions[topic].dup
  end

  def find_subscriber(topic, name)
    @subscriptions[topic].find { |s| s.name == name }
  end

  def subscriber_count(topic)
    @subscriptions[topic].size
  end

  private

  def subscriber_exists?(topic, name)
    @subscriptions[topic].any? { |s| s.name == name }
  end
end

class MessageStore
  def initialize
    @messages = Hash.new { |h, k| h[k] = [] }
    @mutex = Mutex.new
  end

  def store(topic, message)
    @mutex.synchronize do
      @messages[topic] << message
      cleanup_expired(topic)
    end
  end

  def get_messages(topic)
    @mutex.synchronize do
      cleanup_expired(topic)
      @messages[topic].dup
    end
  end

  def message_count(topic)
    @messages[topic].size
  end

  private

  def cleanup_expired(topic)
    @messages[topic].delete_if { |msg| msg.expired?(topic.retention_policy) }
  end
end

class RetentionPolicy
  def initialize(period:)
    @period = period
  end

  def expired?(published_at)
    (Time.now - published_at) > @period
  end
end

class DeadLetterQueue
  def initialize
    @failed_deliveries = []
    @mutex = Mutex.new
  end

  def add(message:, subscriber:, error:)
    @mutex.synchronize do
      @failed_deliveries << FailedDelivery.new(
        message: message,
        subscriber_name: subscriber.name,
        error: error,
        failed_at: Time.now
      )
    end
  end

  def count_by_topic(topic)
    @failed_deliveries.count { |fd| fd.message.topic == topic }
  end
end

class FailedDelivery
  attr_reader :message, :subscriber_name, :error, :failed_at

  def initialize(message:, subscriber_name:, error:, failed_at:)
    @message = message
    @subscriber_name = subscriber_name
    @error = error
    @failed_at = failed_at
  end
end

class MessageQuery
  def initialize(messages)
    @messages = messages
  end

  def order_by_newest
    @messages = @messages.sort_by(&:published_at).reverse
    self
  end

  def limit(count)
    @messages = @messages.take(count)
    self
  end

  def execute
    @messages
  end
end

class StatisticsCollector
  def initialize(topics:, message_store:, subscription_manager:, dead_letter_queue:)
    @topics = topics
    @message_store = message_store
    @subscription_manager = subscription_manager
    @dead_letter_queue = dead_letter_queue
  end

  def collect
    @topics.each_with_object({}) do |topic, stats|
      stats[topic.name] = TopicStatistics.new(
        message_count: @message_store.message_count(topic),
        subscriber_count: @subscription_manager.subscriber_count(topic),
        failed_count: @dead_letter_queue.count_by_topic(topic)
      ).to_h
    end
  end
end

class TopicStatistics
  def initialize(message_count:, subscriber_count:, failed_count:)
    @message_count = message_count
    @subscriber_count = subscriber_count
    @failed_count = failed_count
  end

  def to_h
    {
      message_count: @message_count,
      subscriber_count: @subscriber_count,
      failed_count: @failed_count
    }
  end
end

class SubscriberStatistics
  def initialize
    @success_count = 0
    @error_count = 0
  end

  def record_success
    @success_count += 1
  end

  def record_error
    @error_count += 1
  end

  def summary
    {
      message_count: @success_count,
      error_count: @error_count
    }
  end
end

class SubscriptionResult
  def self.success
    new(success: true)
  end

  def self.failure(reason)
    new(success: false, reason: reason)
  end

  def initialize(success:, reason: nil)
    @success = success
    @reason = reason
  end

  def success?
    @success
  end
end

class PublishResult
  def self.success(message_id:, delivered_count:)
    new(success: true, message_id: message_id, delivered_count: delivered_count)
  end

  def self.failure(reason)
    new(success: false, reason: reason)
  end

  def initialize(success:, message_id: nil, delivered_count: nil, reason: nil)
    @success = success
    @message_id = message_id
    @delivered_count = delivered_count
    @reason = reason
  end

  def to_h
    return { error: @reason } unless @success

    { id: @message_id, delivered_to: @delivered_count }
  end
end
