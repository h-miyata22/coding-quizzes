class SalesReport
  def generate_report(sales_data)
    result = {}

    # 合計金額を計算
    total = 0
    for i in 0..sales_data.length - 1
      total += sales_data[i][:amount] if sales_data[i][:status] != 'cancelled'
    end
    result[:total] = total

    # 平均を計算
    count = 0
    for i in 0..sales_data.length - 1
      count += 1 if sales_data[i][:status] != 'cancelled'
    end
    result[:average] = if count > 0
                         total / count
                       else
                         0
                       end

    # 最大値を探す
    max = nil
    for i in 0..sales_data.length - 1
      next unless sales_data[i][:status] != 'cancelled'

      max = sales_data[i][:amount] if max.nil? || sales_data[i][:amount] > max
    end
    result[:max] = max

    # カテゴリ別の集計
    categories = {}
    for i in 0..sales_data.length - 1
      next unless sales_data[i][:status] != 'cancelled'

      cat = sales_data[i][:category]
      categories[cat] = 0 if categories[cat].nil?
      categories[cat] = categories[cat] + sales_data[i][:amount]
    end
    result[:by_category] = categories

    # VIP顧客の売上
    vip_total = 0
    for i in 0..sales_data.length - 1
      vip_total += sales_data[i][:amount] if sales_data[i][:status] != 'cancelled' && sales_data[i][:is_vip] == true
    end
    result[:vip_sales] = vip_total

    result
  end
end
