class ShoppingCart
  DEFAULT_TAX_RATE = 0.08
  FREE_SHIPPING_THRESHOLD = 3000
  STANDARD_SHIPPING_FEE = 500
  MEMBER_DISCOUNT_RATE = 0.05

  attr_reader :items, :total

  def initialize(tax_rate: DEFAULT_TAX_RATE)
    @items = []
    @pricing_strategy = PricingStrategy.new(tax_rate: tax_rate)
    @applied_coupons = []
  end

  def add_item(item)
    return false unless valid_item?(item)

    existing_item = find_item(item[:id])

    if existing_item
      existing_item[:quantity] += item[:quantity]
    else
      @items << item.dup
    end

    true
  end

  def remove_item(item_id)
    return false unless @items.reject! { |item| item[:id] == item_id }

    true
  end

  def apply_coupon(code)
    coupon = CouponRepository.find(code)
    return false unless coupon

    @applied_coupons << coupon
    true
  end

  def set_member(is_member)
    @pricing_strategy.is_member = is_member
  end

  def total
    @pricing_strategy.calculate(
      items: @items,
      coupons: @applied_coupons
    )
  end

  private

  def valid_item?(item)
    item && item[:quantity] && item[:quantity] > 0
  end

  def find_item(item_id)
    @items.find { |item| item[:id] == item_id }
  end
end

class PricingStrategy
  attr_accessor :is_member

  def initialize(tax_rate:)
    @tax_rate = tax_rate
    @is_member = false
  end

  def calculate(items:, coupons:)
    calculator = PriceCalculator.new(
      items: items,
      coupons: coupons,
      is_member: @is_member,
      tax_rate: @tax_rate
    )

    calculator.total
  end
end

class PriceCalculator
  def initialize(items:, coupons:, is_member:, tax_rate:)
    @items = items
    @coupons = coupons
    @is_member = is_member
    @tax_rate = tax_rate
  end

  def total
    subtotal + tax + shipping_fee
  end

  private

  def subtotal
    @subtotal ||= calculate_subtotal
  end

  def calculate_subtotal
    base_total = @items.sum { |item| item[:price] * item[:quantity] }
    base_total - discount_amount(base_total)
  end

  def discount_amount(base_total)
    total_discount_rate = calculate_total_discount_rate
    base_total * total_discount_rate
  end

  def calculate_total_discount_rate
    discount_rate = @coupons.sum(&:discount_rate)
    discount_rate += ShoppingCart::MEMBER_DISCOUNT_RATE if @is_member
    [discount_rate, 1.0].min # 最大100%割引
  end

  def tax
    subtotal * @tax_rate
  end

  def shipping_fee
    return 0 if free_shipping?

    subtotal >= ShoppingCart::FREE_SHIPPING_THRESHOLD ? 0 : ShoppingCart::STANDARD_SHIPPING_FEE
  end

  def free_shipping?
    @coupons.any?(&:free_shipping?)
  end
end

class Coupon
  attr_reader :code, :discount_rate

  def initialize(code:, discount_rate: 0, free_shipping: false)
    @code = code
    @discount_rate = discount_rate
    @free_shipping = free_shipping
  end

  def free_shipping?
    @free_shipping
  end
end

class CouponRepository
  COUPONS = {
    'SAVE10' => Coupon.new(code: 'SAVE10', discount_rate: 0.1),
    'SAVE20' => Coupon.new(code: 'SAVE20', discount_rate: 0.2),
    'FREESHIP' => Coupon.new(code: 'FREESHIP', free_shipping: true)
  }.freeze

  def self.find(code)
    COUPONS[code]
  end
end
