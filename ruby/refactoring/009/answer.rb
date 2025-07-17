class OrderProcessor
  def initialize
    @event_bus = EventBus.new
    setup_event_handlers
  end

  def process_order(order)
    validator = OrderValidator.new
    validation_result = validator.validate(order)

    return validation_result unless validation_result[:success]

    ActiveRecord::Base.transaction do
      confirm_order(order)
      @event_bus.publish(:order_confirmed, order)
    end

    { success: true, order_id: order.id }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def setup_event_handlers
    @event_bus.subscribe(:order_confirmed, StockReducer.new)
    @event_bus.subscribe(:order_confirmed, CustomerNotifier.new)
    @event_bus.subscribe(:order_confirmed, SlackNotifier.new)
    @event_bus.subscribe(:order_confirmed, PointsManager.new)
    @event_bus.subscribe(:order_confirmed, AnalyticsTracker.new)
    @event_bus.subscribe(:order_confirmed, ShipmentCreator.new)
  end

  def confirm_order(order)
    order.status = 'confirmed'
    order.confirmed_at = Time.now
    order.save!
  end
end

class EventBus
  def initialize
    @handlers = Hash.new { |h, k| h[k] = [] }
  end

  def subscribe(event, handler)
    @handlers[event] << handler
  end

  def publish(event, data)
    @handlers[event].each do |handler|
      handler.handle(data)
    rescue StandardError => e
      # エラーログを記録し、処理を続行
      Rails.logger.error "Event handler error: #{e.message}"
    end
  end
end

class OrderValidator
  def validate(order)
    stock_checker = StockChecker.new

    order.items.each do |item|
      unless stock_checker.available?(item[:product_id], item[:quantity])
        return {
          success: false,
          error: "Insufficient stock for #{item[:product_name]}"
        }
      end
    end

    { success: true }
  end
end

class StockChecker
  def available?(product_id, quantity)
    StockManager.check_stock(product_id) >= quantity
  end
end

class StockReducer
  def handle(order)
    order.items.each do |item|
      StockManager.reduce_stock(item[:product_id], item[:quantity])
    end
  end
end

class CustomerNotifier
  def handle(order)
    EmailBuilder.new(order).send_confirmation
  end
end

class EmailBuilder
  def initialize(order)
    @order = order
  end

  def send_confirmation
    EmailService.send(
      to: @order.customer_email,
      subject: "Order Confirmation ##{@order.id}",
      body: build_confirmation_body
    )
  end

  private

  def build_confirmation_body
    <<~BODY
      Dear #{@order.customer_name},

      Your order ##{@order.id} has been confirmed.

      Order details:
      #{order_items_text}

      Total: $#{@order.total_amount}

      Thank you for your purchase!
    BODY
  end

  def order_items_text
    @order.items.map do |item|
      "- #{item[:product_name]} x#{item[:quantity]} = $#{item[:price] * item[:quantity]}"
    end.join("\n")
  end
end

class SlackNotifier
  SALES_CHANNEL = '#sales'

  def handle(order)
    message = format_message(order)
    SlackNotifier.notify(SALES_CHANNEL, message)
  end

  private

  def format_message(order)
    "New order ##{order.id} from #{order.customer_name} - Total: $#{order.total_amount}"
  end

  def self.notify(channel, message)
    # Slack API 呼び出し
  end
end

class PointsManager
  POINTS_RATE = 0.01

  def handle(order)
    return unless order.customer_id

    points = calculate_points(order.total_amount)
    CustomerService.add_points(order.customer_id, points)

    send_points_notification(order, points)
  end

  private

  def calculate_points(amount)
    (amount * POINTS_RATE).to_i
  end

  def send_points_notification(order, points)
    EmailService.send(
      to: order.customer_email,
      subject: 'Points Earned!',
      body: "You've earned #{points} points from your recent purchase!"
    )
  end
end

class AnalyticsTracker
  def handle(order)
    Analytics.track('order_completed', build_analytics_data(order))
  end

  private

  def build_analytics_data(order)
    {
      order_id: order.id,
      customer_id: order.customer_id,
      total: order.total_amount,
      items_count: order.items.count
    }
  end
end

class ShipmentCreator
  def handle(order)
    ShippingService.create_shipment(build_shipment_data(order))
  end

  private

  def build_shipment_data(order)
    {
      order_id: order.id,
      address: order.shipping_address,
      items: order.items
    }
  end
end
