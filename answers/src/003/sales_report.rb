class SalesReport
  def initialize(sales_data)
    @sales_data = sales_data
  end

  def execute
    {
      total: total(valid_sales_data),
      average: average(valid_sales_data),
      max: max(valid_sales_data),
      by_category: by_category(valid_sales_data),
      vip_sales: vip_sales(valid_sales_data)
    }
  end

  private

  def valid_sales_data
    return [] if @sales_data.nil?

    @sales_data.reject { |data| data[:status] == 'cancelled' }
  end

  def total(sales_data)
    sales_data.sum { |data| data[:amount] }
  end

  def average(sales_data)
    total(sales_data) / sales_data.count
  end

  def max(sales_data)
    return 0 if sales_data.empty?

    sales_data.max_by { |data| data[:amount] }[:amount]
  end

  def by_category(sales_data)
    categories = {}

    grouped_sales_data = sales_data.group_by { |data| data[:category] }
    grouped_sales_data.each do |category, data|
      categories[category] = total(data)
    end

    categories
  end

  def vip_sales(sales_data)
    total(sales_data.select { |data| data[:is_vip] })
  end
end
