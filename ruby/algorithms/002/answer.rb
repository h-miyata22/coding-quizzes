require 'time'

class Order
  attr_reader :item, :priority, :created_at, :processed_at
  attr_accessor :status

  def initialize(item, priority)
    @item = item
    @priority = priority
    @created_at = Time.now
    @processed_at = nil
    @status = :pending
  end

  def process!
    @processed_at = Time.now
    @status = :completed
  end

  def processing_time
    return nil unless @processed_at

    @processed_at - @created_at
  end

  def urgent?
    @priority == :urgent
  end

  def to_s
    "Order(item: \"#{@item}\", priority: #{@priority})"
  end
end

# 連結リストのノード
class Node
  attr_accessor :order, :next_node

  def initialize(order)
    @order = order
    @next_node = nil
  end
end

# オブザーバーのインターフェース
module OrderObserver
  def order_added(order)
    raise NotImplementedError
  end

  def order_processed(order)
    raise NotImplementedError
  end
end

class OrderQueue
  def initialize
    @urgent_head = nil
    @urgent_tail = nil
    @normal_head = nil
    @normal_tail = nil
    @observers = []
    @processed_orders = []
  end

  def add_order(item, priority)
    order = Order.new(item, priority)

    if order.urgent?
      add_to_urgent_queue(order)
    else
      add_to_normal_queue(order)
    end

    notify_observers(:order_added, order)
    order
  end

  def process_next_order
    order = nil

    # 急ぎの注文を優先
    if @urgent_head
      order = @urgent_head.order
      @urgent_head = @urgent_head.next_node
      @urgent_tail = nil if @urgent_head.nil?
    elsif @normal_head
      order = @normal_head.order
      @normal_head = @normal_head.next_node
      @normal_tail = nil if @normal_head.nil?
    end

    return nil unless order

    order.process!
    @processed_orders << order
    notify_observers(:order_processed, order)
    order
  end

  def average_processing_time
    return 0 if @processed_orders.empty?

    total_time = @processed_orders.sum { |order| order.processing_time }
    total_time / @processed_orders.length
  end

  def add_observer(observer)
    @observers << observer
  end

  def remove_observer(observer)
    @observers.delete(observer)
  end

  def pending_orders_count
    count_queue(@urgent_head) + count_queue(@normal_head)
  end

  private

  def add_to_urgent_queue(order)
    node = Node.new(order)

    if @urgent_tail
      @urgent_tail.next_node = node
      @urgent_tail = node
    else
      @urgent_head = @urgent_tail = node
    end
  end

  def add_to_normal_queue(order)
    node = Node.new(order)

    if @normal_tail
      @normal_tail.next_node = node
      @normal_tail = node
    else
      @normal_head = @normal_tail = node
    end
  end

  def notify_observers(event, order)
    @observers.each do |observer|
      case event
      when :order_added
        observer.order_added(order) if observer.respond_to?(:order_added)
      when :order_processed
        observer.order_processed(order) if observer.respond_to?(:order_processed)
      end
    end
  end

  def count_queue(head)
    count = 0
    current = head
    while current
      count += 1
      current = current.next_node
    end
    count
  end
end

# 実装例：キッチンディスプレイ
class KitchenDisplay
  include OrderObserver

  def order_added(order)
    puts "[Kitchen] New order received: #{order}"
  end

  def order_processed(order)
    puts "[Kitchen] Order completed: #{order} (Processing time: #{'%.2f' % order.processing_time}s)"
  end
end

# テスト
if __FILE__ == $0
  queue = OrderQueue.new

  # オブザーバーを登録
  kitchen_display = KitchenDisplay.new
  queue.add_observer(kitchen_display)

  puts '=== Adding orders ==='
  queue.add_order('ハンバーガー', :normal)
  sleep(0.1)
  queue.add_order('サラダ', :urgent)
  sleep(0.1)
  queue.add_order('ポテト', :normal)
  sleep(0.1)
  queue.add_order('スープ', :urgent)

  puts "\nPending orders: #{queue.pending_orders_count}"

  puts "\n=== Processing orders ==="
  while queue.pending_orders_count > 0
    sleep(0.2) # 処理時間をシミュレート
    queue.process_next_order
  end

  puts "\n=== Statistics ==="
  puts "Average processing time: #{'%.2f' % queue.average_processing_time}s"
end
