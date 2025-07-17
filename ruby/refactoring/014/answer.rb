class PricingCalculator
  def initialize(rules: PricingRules.new)
    @rules = rules
  end

  def calculate_price(product, quantity, customer)
    PriceCalculation.new(product, quantity, customer, @rules).calculate
  end
end

class PriceCalculation
  def initialize(product, quantity, customer, rules)
    @product = product
    @quantity = quantity
    @customer = customer
    @rules = rules
  end

  def calculate
    price = base_price

    @rules.applicable_discounts(@product, @quantity, @customer).each do |discount|
      price = discount.apply(price)
    end

    ensure_minimum_price(price)
  end

  private

  def base_price
    @product.price * @quantity
  end

  def ensure_minimum_price(price)
    minimum = @product.cost * PricingRules::MINIMUM_MARGIN_RATE
    rounded_price = (price * 100).round / 100.0

    [rounded_price, minimum].max
  end
end

class PricingRules
  MINIMUM_MARGIN_RATE = 1.1

  def applicable_discounts(product, quantity, customer)
    discounts = []

    discounts << CategoryDiscount.new(product, quantity)
    discounts << CustomerRankDiscount.new(customer)
    discounts.concat(seasonal_discounts(product))
    discounts << BundleDiscount.new(product, customer)

    discounts.select(&:applicable?)
  end

  private

  def seasonal_discounts(product)
    SeasonalSale.active_sales.map { |sale| sale.discount_for(product) }.compact
  end
end

class Discount
  def apply(price)
    price * (1 - discount_rate)
  end

  def applicable?
    discount_rate > 0
  end

  protected

  def discount_rate
    0
  end
end

class CategoryDiscount < Discount
  DISCOUNT_RULES = {
    electronics: { 5 => 0.15, 3 => 0.10 },
    books: { 10 => 0.20, 5 => 0.10 },
    clothing: { 3 => 0.25 }
  }.freeze

  def initialize(product, quantity)
    @product = product
    @quantity = quantity
  end

  protected

  def discount_rate
    rules = DISCOUNT_RULES[@product.category.to_sym] || {}

    rules.sort_by { |min_qty, _| -min_qty }.each do |min_quantity, rate|
      return rate if @quantity >= min_quantity
    end

    0
  end
end

class CustomerRankDiscount < Discount
  RANK_DISCOUNTS = {
    gold: 0.10,
    silver: 0.05,
    bronze: 0.03
  }.freeze

  def initialize(customer)
    @customer = customer
  end

  protected

  def discount_rate
    RANK_DISCOUNTS[@customer.rank.to_sym] || 0
  end
end

class SeasonalSale
  attr_reader :name, :start_date, :end_date, :applicable_categories, :discount_rate

  def self.active_sales
    ALL_SALES.select(&:active?)
  end

  def initialize(name:, start_date:, end_date:, applicable_categories:, discount_rate:)
    @name = name
    @start_date = start_date
    @end_date = end_date
    @applicable_categories = applicable_categories
    @discount_rate = discount_rate
  end

  def active?
    current_time = Time.now
    current_time >= @start_date && current_time <= @end_date
  end

  def discount_for(product)
    return nil unless @applicable_categories.include?(product.category.to_sym)

    SeasonalDiscount.new(@discount_rate)
  end

  ALL_SALES = [
    new(
      name: 'Christmas Sale',
      start_date: Time.new(2024, 12, 1),
      end_date: Time.new(2024, 12, 31),
      applicable_categories: %i[electronics toys],
      discount_rate: 0.20
    ),
    new(
      name: 'Black Friday',
      start_date: Time.new(2024, 11, 24),
      end_date: Time.new(2024, 11, 27),
      applicable_categories: %i[electronics books clothing toys],
      discount_rate: 0.30
    )
  ].freeze
end

class SeasonalDiscount < Discount
  def initialize(rate)
    @rate = rate
  end

  protected

  def discount_rate
    @rate
  end
end

class BundleDiscount < Discount
  REQUIRED_ITEMS = 3
  BUNDLE_DISCOUNT_RATE = 0.10

  def initialize(product, customer)
    @product = product
    @customer = customer
  end

  protected

  def discount_rate
    return 0 unless @customer.cart

    same_category_count = @customer.cart.count { |item| item.category == @product.category }

    same_category_count >= REQUIRED_ITEMS ? BUNDLE_DISCOUNT_RATE : 0
  end
end
