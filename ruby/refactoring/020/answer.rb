class InventoryManager
  def initialize
    @product_repository = ProductRepository.new
    @warehouse_repository = WarehouseRepository.new
    @transaction_log = TransactionLog.new
    @alert_service = AlertService.new
  end

  def add_product(id, name, price, warehouse_id, quantity)
    product = Product.new(id: id, name: name, price: Money.new(price))

    return OperationResult.failure('Product already exists') if @product_repository.exists?(id)

    @product_repository.add(product)
    warehouse = @warehouse_repository.find_or_create(warehouse_id)

    stock_entry = StockEntry.new(product: product, quantity: Quantity.new(quantity))
    warehouse.add_stock(stock_entry)

    transaction = StockAdditionTransaction.new(
      product: product,
      warehouse: warehouse,
      quantity: stock_entry.quantity
    )

    @transaction_log.record(transaction)
    @alert_service.check_stock_levels(product, calculate_total_quantity(product))

    OperationResult.success
  end

  def transfer_stock(product_id, from_warehouse_id, to_warehouse_id, quantity)
    transfer_command = TransferStockCommand.new(
      product_repository: @product_repository,
      warehouse_repository: @warehouse_repository,
      transaction_log: @transaction_log,
      alert_service: @alert_service
    )

    transfer_command.execute(
      product_id: product_id,
      from_warehouse_id: from_warehouse_id,
      to_warehouse_id: to_warehouse_id,
      quantity: Quantity.new(quantity)
    )
  end

  def sell_product(product_id, warehouse_id, quantity, customer_name)
    sale_command = SellProductCommand.new(
      product_repository: @product_repository,
      warehouse_repository: @warehouse_repository,
      transaction_log: @transaction_log,
      alert_service: @alert_service
    )

    sale_command.execute(
      product_id: product_id,
      warehouse_id: warehouse_id,
      quantity: Quantity.new(quantity),
      customer: Customer.new(customer_name)
    )
  end

  def get_inventory_report
    InventoryReportBuilder.new(
      product_repository: @product_repository,
      warehouse_repository: @warehouse_repository
    ).build
  end

  def get_low_stock_alert(threshold = 10)
    @alert_service.get_low_stock_alerts(
      @product_repository.all,
      Quantity.new(threshold)
    )
  end

  private

  def calculate_total_quantity(product)
    @warehouse_repository.all
                         .map { |warehouse| warehouse.quantity_for(product) }
                         .reduce(Quantity.zero, :+)
  end
end

class Product
  attr_reader :id, :name, :price

  def initialize(id:, name:, price:)
    @id = id
    @name = name
    @price = price
  end

  def ==(other)
    other.is_a?(Product) && other.id == id
  end

  alias eql? ==

  def hash
    id.hash
  end
end

class Warehouse
  attr_reader :id

  def initialize(id)
    @id = id
    @inventory = Inventory.new
  end

  def add_stock(stock_entry)
    @inventory.add(stock_entry)
  end

  def remove_stock(product, quantity)
    @inventory.remove(product, quantity)
  end

  def has_stock?(product, quantity)
    @inventory.has_stock?(product, quantity)
  end

  def quantity_for(product)
    @inventory.quantity_for(product)
  end

  def all_stock_entries
    @inventory.all_entries
  end

  def total_value
    @inventory.total_value
  end

  def total_items
    @inventory.total_items
  end
end

class Inventory
  def initialize
    @stock_entries = {}
  end

  def add(stock_entry)
    product = stock_entry.product
    current = @stock_entries[product] || StockEntry.new(product: product, quantity: Quantity.zero)
    @stock_entries[product] = current.add_quantity(stock_entry.quantity)
  end

  def remove(product, quantity)
    return OperationResult.failure('Product not found') unless @stock_entries[product]

    current = @stock_entries[product]
    return OperationResult.failure('Insufficient stock') unless current.has_quantity?(quantity)

    @stock_entries[product] = current.subtract_quantity(quantity)
    OperationResult.success
  end

  def has_stock?(product, quantity)
    return false unless @stock_entries[product]

    @stock_entries[product].has_quantity?(quantity)
  end

  def quantity_for(product)
    @stock_entries[product]&.quantity || Quantity.zero
  end

  def all_entries
    @stock_entries.values
  end

  def total_value
    @stock_entries.values
                  .map(&:total_value)
                  .reduce(Money.zero, :+)
  end

  def total_items
    @stock_entries.values
                  .map(&:quantity)
                  .reduce(Quantity.zero, :+)
  end
end

class StockEntry
  attr_reader :product, :quantity

  def initialize(product:, quantity:)
    @product = product
    @quantity = quantity
  end

  def add_quantity(amount)
    StockEntry.new(product: @product, quantity: @quantity + amount)
  end

  def subtract_quantity(amount)
    StockEntry.new(product: @product, quantity: @quantity - amount)
  end

  def has_quantity?(amount)
    @quantity >= amount
  end

  def total_value
    @product.price * @quantity.value
  end
end

class Money
  attr_reader :amount

  def initialize(amount)
    @amount = amount
  end

  def self.zero
    new(0)
  end

  def +(other)
    Money.new(@amount + other.amount)
  end

  def *(other)
    Money.new(@amount * other)
  end

  def to_s
    "$#{@amount}"
  end
end

class Quantity
  attr_reader :value

  def initialize(value)
    raise ArgumentError, 'Quantity must be non-negative' if value < 0

    @value = value
  end

  def self.zero
    new(0)
  end

  def +(other)
    Quantity.new(@value + other.value)
  end

  def -(other)
    Quantity.new(@value - other.value)
  end

  def >=(other)
    @value >= other.value
  end

  def <(other)
    @value < other.value
  end

  def to_s
    @value.to_s
  end
end

class Customer
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Transaction
  attr_reader :timestamp

  def initialize
    @timestamp = Time.now
  end

  def type
    self.class.name.sub('Transaction', '').upcase
  end
end

class StockAdditionTransaction < Transaction
  attr_reader :product, :warehouse, :quantity

  def initialize(product:, warehouse:, quantity:)
    super()
    @product = product
    @warehouse = warehouse
    @quantity = quantity
  end
end

class TransferTransaction < Transaction
  attr_reader :product, :from_warehouse, :to_warehouse, :quantity

  def initialize(product:, from_warehouse:, to_warehouse:, quantity:)
    super()
    @product = product
    @from_warehouse = from_warehouse
    @to_warehouse = to_warehouse
    @quantity = quantity
  end
end

class SaleTransaction < Transaction
  attr_reader :product, :warehouse, :quantity, :customer, :total_price

  def initialize(product:, warehouse:, quantity:, customer:, total_price:)
    super()
    @product = product
    @warehouse = warehouse
    @quantity = quantity
    @customer = customer
    @total_price = total_price
  end
end

class TransferStockCommand
  def initialize(product_repository:, warehouse_repository:, transaction_log:, alert_service:)
    @product_repository = product_repository
    @warehouse_repository = warehouse_repository
    @transaction_log = transaction_log
    @alert_service = alert_service
  end

  def execute(product_id:, from_warehouse_id:, to_warehouse_id:, quantity:)
    product = @product_repository.find(product_id)
    return OperationResult.failure('Product not found') unless product

    from_warehouse = @warehouse_repository.find(from_warehouse_id)
    return OperationResult.failure('Source warehouse not found') unless from_warehouse

    to_warehouse = @warehouse_repository.find_or_create(to_warehouse_id)

    return OperationResult.failure('Insufficient stock') unless from_warehouse.has_stock?(product, quantity)

    from_warehouse.remove_stock(product, quantity)
    to_warehouse.add_stock(StockEntry.new(product: product, quantity: quantity))

    transaction = TransferTransaction.new(
      product: product,
      from_warehouse: from_warehouse,
      to_warehouse: to_warehouse,
      quantity: quantity
    )

    @transaction_log.record(transaction)

    OperationResult.success
  end
end

class SellProductCommand
  def initialize(product_repository:, warehouse_repository:, transaction_log:, alert_service:)
    @product_repository = product_repository
    @warehouse_repository = warehouse_repository
    @transaction_log = transaction_log
    @alert_service = alert_service
  end

  def execute(product_id:, warehouse_id:, quantity:, customer:)
    product = @product_repository.find(product_id)
    return OperationResult.failure('Product not found') unless product

    warehouse = @warehouse_repository.find(warehouse_id)
    return OperationResult.failure('Warehouse not found') unless warehouse

    return OperationResult.failure('Insufficient stock') unless warehouse.has_stock?(product, quantity)

    total_price = product.price * quantity.value

    warehouse.remove_stock(product, quantity)

    transaction = SaleTransaction.new(
      product: product,
      warehouse: warehouse,
      quantity: quantity,
      customer: customer,
      total_price: total_price
    )

    @transaction_log.record(transaction)
    @alert_service.check_stock_levels(product, calculate_total_quantity(product))

    OperationResult.success(
      SaleReceipt.new(
        product: product,
        quantity: quantity,
        total_price: total_price
      )
    )
  end

  private

  def calculate_total_quantity(product)
    @warehouse_repository.all
                         .map { |warehouse| warehouse.quantity_for(product) }
                         .reduce(Quantity.zero, :+)
  end
end

class SaleReceipt
  attr_reader :product, :quantity, :total_price

  def initialize(product:, quantity:, total_price:)
    @product = product
    @quantity = quantity
    @total_price = total_price
  end

  def to_h
    {
      product: @product.name,
      quantity: @quantity.value,
      total_price: @total_price.amount
    }
  end
end

class OperationResult
  attr_reader :value, :error

  def initialize(success:, value: nil, error: nil)
    @success = success
    @value = value
    @error = error
  end

  def self.success(value = true)
    new(success: true, value: value)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end

class ProductRepository
  def initialize
    @products = {}
  end

  def add(product)
    @products[product.id] = product
  end

  def find(id)
    @products[id]
  end

  def exists?(id)
    @products.key?(id)
  end

  def all
    @products.values
  end
end

class WarehouseRepository
  def initialize
    @warehouses = {}
  end

  def find(id)
    @warehouses[id]
  end

  def find_or_create(id)
    @warehouses[id] ||= Warehouse.new(id)
  end

  def all
    @warehouses.values
  end
end

class TransactionLog
  def initialize
    @transactions = []
  end

  def record(transaction)
    @transactions << transaction
    puts "[#{transaction.timestamp}] #{transaction.type} transaction recorded"
  end

  def all
    @transactions
  end
end

class AlertService
  LOW_STOCK_THRESHOLD = Quantity.new(10)

  def check_stock_levels(product, total_quantity)
    return unless total_quantity < LOW_STOCK_THRESHOLD

    send_low_stock_alert(product, total_quantity)
  end

  def get_low_stock_alerts(products, threshold)
    products.select do |product|
      total_quantity = calculate_total_quantity(product)
      total_quantity < threshold
    end.map do |product|
      total_quantity = calculate_total_quantity(product)
      "LOW STOCK: #{product.name} - Only #{total_quantity} units remaining"
    end
  end

  private

  def send_low_stock_alert(product, quantity)
    puts "ALERT: Low stock for #{product.name} - #{quantity} units remaining"
  end

  def calculate_total_quantity(_product)
    # This would need access to warehouse repository in real implementation
    Quantity.zero
  end
end

class InventoryReportBuilder
  def initialize(product_repository:, warehouse_repository:)
    @product_repository = product_repository
    @warehouse_repository = warehouse_repository
  end

  def build
    sections = []
    sections << build_product_section
    sections << build_warehouse_section

    sections.join("\n")
  end

  private

  def build_product_section
    ReportSection.new('INVENTORY REPORT').tap do |section|
      @product_repository.all.each do |product|
        section.add_product_details(product, product_locations(product))
      end
    end.to_s
  end

  def build_warehouse_section
    ReportSection.new('WAREHOUSE SUMMARY').tap do |section|
      @warehouse_repository.all.each do |warehouse|
        section.add_warehouse_summary(warehouse)
      end
    end.to_s
  end

  def product_locations(product)
    @warehouse_repository.all.map do |warehouse|
      quantity = warehouse.quantity_for(product)
      [warehouse.id, quantity] if quantity.value > 0
    end.compact
  end
end

class ReportSection
  def initialize(title)
    @title = title
    @content = []
  end

  def add_product_details(product, locations)
    total_quantity = locations.sum { |_, quantity| quantity.value }

    @content << "Product: #{product.name}"
    @content << "  Total Quantity: #{total_quantity}"
    @content << "  Price: #{product.price}"
    @content << "  Total Value: #{product.price * total_quantity}"
    @content << '  Locations:'

    locations.each do |warehouse_id, quantity|
      @content << "    #{warehouse_id}: #{quantity} units"
    end

    @content << ''
  end

  def add_warehouse_summary(warehouse)
    @content << "Warehouse: #{warehouse.id}"
    @content << "  Total Items: #{warehouse.total_items}"
    @content << "  Total Value: #{warehouse.total_value}"
    @content << ''
  end

  def to_s
    header = "#{@title}\n#{'=' * @title.length}\n\n"
    header + @content.join("\n")
  end
end
