class NotificationService
  def initialize(factory: NotificationChannelFactory.new)
    @factory = factory
  end

  def send_notification(user_id, type, data)
    user = User.find(user_id)
    channel = @factory.create(type)

    channel.send_to(user, data) if channel.can_send?(user)
  end

  def send_bulk_notifications(user_ids, type, data)
    BulkNotificationJob.perform_async(user_ids, type, data)
  end
end

class NotificationChannelFactory
  CHANNELS = {
    email: EmailChannel,
    sms: SmsChannel,
    push: PushChannel
  }.freeze

  def create(type)
    channel_class = CHANNELS[type.to_sym]
    raise ArgumentError, "Unknown notification type: #{type}" unless channel_class

    channel_class.new
  end
end

class NotificationChannel
  def send_to(user, data)
    message = build_message(data)
    deliver(user, message)
    log_notification(user, data)
  end

  def can_send?(user)
    raise NotImplementedError
  end

  protected

  def build_message(data)
    template = MessageTemplate.for(self.class, data[:event])
    template.render(data)
  end

  def deliver(user, message)
    raise NotImplementedError
  end

  def log_notification(user, data)
    NotificationLogger.log(
      user_id: user.id,
      type: notification_type,
      event: data[:event]
    )
  end

  def notification_type
    self.class.name.gsub('Channel', '').downcase
  end
end

class EmailChannel < NotificationChannel
  def can_send?(user)
    user.email_enabled && user.email.present?
  end

  protected

  def deliver(user, message)
    EmailSender.send(
      to: user.email,
      subject: message[:subject],
      body: message[:body]
    )
  end
end

class SmsChannel < NotificationChannel
  def can_send?(user)
    user.sms_enabled && user.phone.present?
  end

  protected

  def deliver(user, message)
    SmsSender.send(
      to: user.phone,
      message: message[:message]
    )
  end
end

class PushChannel < NotificationChannel
  def can_send?(user)
    user.push_enabled && user.device_token.present?
  end

  protected

  def deliver(user, message)
    PushNotifier.send(
      device_token: user.device_token,
      title: message[:title],
      message: message[:message]
    )
  end
end

class MessageTemplate
  TEMPLATES = {
    email: {
      order_completed: {
        subject: 'Order Completed!',
        body: 'Your order #{{order_id}} has been completed.'
      },
      payment_received: {
        subject: 'Payment Received',
        body: "We've received your payment of ${{amount}}."
      },
      shipment_sent: {
        subject: 'Your Order Has Shipped!',
        body: 'Your order #{{order_id}} is on its way.'
      }
    },
    sms: {
      order_completed: {
        message: 'Order #{{order_id}} completed!'
      },
      payment_received: {
        message: 'Payment of ${{amount}} received.'
      },
      shipment_sent: {
        message: 'Order #{{order_id}} shipped!'
      }
    },
    push: {
      order_completed: {
        title: 'Order Completed',
        message: 'Your order #{{order_id}} is complete!'
      },
      payment_received: {
        title: 'Payment Received',
        message: '${{amount}} payment confirmed'
      },
      shipment_sent: {
        title: 'Order Shipped',
        message: 'Order #{{order_id}} is on the way!'
      }
    }
  }.freeze

  def self.for(channel_class, event)
    channel_type = channel_class.name.gsub('Channel', '').downcase.to_sym
    template_data = TEMPLATES.dig(channel_type, event.to_sym)

    raise ArgumentError, "No template found for #{channel_type} #{event}" unless template_data

    new(template_data)
  end

  def initialize(template_data)
    @template_data = template_data
  end

  def render(data)
    @template_data.transform_values do |template|
      interpolate(template, data)
    end
  end

  private

  def interpolate(template, data)
    template.gsub(/\{\{(\w+)\}\}/) do |match|
      key = ::Regexp.last_match(1).to_sym
      data[key].to_s
    end
  end
end

class NotificationLogger
  def self.log(attributes)
    NotificationLog.create!(
      attributes.merge(sent_at: Time.current)
    )
  end
end

class BulkNotificationJob
  include Sidekiq::Worker

  def perform(user_ids, type, data)
    service = NotificationService.new

    user_ids.each do |user_id|
      service.send_notification(user_id, type, data)
    rescue StandardError => e
      Rails.logger.error "Failed to send notification to user #{user_id}: #{e.message}"
    end
  end
end
