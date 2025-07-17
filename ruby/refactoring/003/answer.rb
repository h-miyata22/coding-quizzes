class SalesReport
  def generate_report(sales_data)
    valid_sales = filter_valid_sales(sales_data)

    {
      total: calculate_total(valid_sales),
      average: calculate_average(valid_sales),
      max: find_maximum(valid_sales),
      by_category: group_by_category(valid_sales),
      vip_sales: calculate_vip_sales(valid_sales)
    }
  end

  private

  def filter_valid_sales(sales_data)
    sales_data.reject { |sale| sale[:status] == 'cancelled' }
  end

  def calculate_total(sales)
    sales.sum { |sale| sale[:amount] }
  end

  def calculate_average(sales)
    return 0 if sales.empty?

    calculate_total(sales).to_f / sales.size
  end

  def find_maximum(sales)
    sales.map { |sale| sale[:amount] }.max
  end

  def group_by_category(sales)
    sales.group_by { |sale| sale[:category] }
         .transform_values { |category_sales| calculate_total(category_sales) }
  end

  def calculate_vip_sales(sales)
    vip_sales = sales.select { |sale| sale[:is_vip] }
    calculate_total(vip_sales)
  end
end
