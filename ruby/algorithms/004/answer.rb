require 'time'
require 'benchmark'

class Product
  attr_reader :name, :price, :stock, :category, :updated_at

  def initialize(name, price, stock, category, updated_at)
    @name = name
    @price = price
    @stock = stock
    @category = category
    @updated_at = updated_at
  end

  def to_s
    "#{@name} (¥#{@price}, 在庫:#{@stock})"
  end
end

# ソート戦略の基底クラス
class SortStrategy
  def sort(products, &comparator)
    raise NotImplementedError
  end

  def name
    self.class.name.gsub(/Strategy$/, '').gsub(/([A-Z])/, '_\1').downcase[1..-1]
  end
end

# クイックソート戦略
class QuickSortStrategy < SortStrategy
  def sort(products, &comparator)
    return products if products.length <= 1

    pivot = products[products.length / 2]
    left = []
    middle = []
    right = []

    products.each do |product|
      comparison = comparator.call(product, pivot)
      if comparison < 0
        left << product
      elsif comparison > 0
        right << product
      else
        middle << product
      end
    end

    sort(left, &comparator) + middle + sort(right, &comparator)
  end
end

# マージソート戦略
class MergeSortStrategy < SortStrategy
  def sort(products, &comparator)
    return products if products.length <= 1

    mid = products.length / 2
    left = sort(products[0...mid], &comparator)
    right = sort(products[mid..-1], &comparator)

    merge(left, right, &comparator)
  end

  private

  def merge(left, right, &comparator)
    result = []
    i = j = 0

    while i < left.length && j < right.length
      if comparator.call(left[i], right[j]) <= 0
        result << left[i]
        i += 1
      else
        result << right[j]
        j += 1
      end
    end

    result.concat(left[i..-1]) if i < left.length
    result.concat(right[j..-1]) if j < right.length
    result
  end
end

# 挿入ソート戦略
class InsertionSortStrategy < SortStrategy
  def sort(products, &comparator)
    products = products.dup

    (1...products.length).each do |i|
      key = products[i]
      j = i - 1

      while j >= 0 && comparator.call(products[j], key) > 0
        products[j + 1] = products[j]
        j -= 1
      end

      products[j + 1] = key
    end

    products
  end
end

class InventoryManager
  def initialize
    @products = []
    @sort_strategies = {
      quick_sort: QuickSortStrategy.new,
      merge_sort: MergeSortStrategy.new,
      insertion_sort: InsertionSortStrategy.new
    }
  end

  def add_product(name, price, stock, category, updated_at)
    @products << Product.new(name, price, stock, category, updated_at)
  end

  def sort_products(by: nil, order: :asc, &block)
    comparator = if block_given?
                   block
                 else
                   create_comparator(by, order)
                 end

    strategy = select_strategy(@products.length)
    strategy.sort(@products, &comparator)
  end

  def sort_with_benchmark(by: nil, order: :asc, algorithm: nil, &block)
    comparator = if block_given?
                   block
                 else
                   create_comparator(by, order)
                 end

    strategy = algorithm ? @sort_strategies[algorithm] : select_strategy(@products.length)

    time = Benchmark.realtime do
      @sorted_products = strategy.sort(@products, &comparator)
    end

    {
      products: @sorted_products,
      algorithm: strategy.name,
      time: time,
      count: @products.length
    }
  end

  def benchmark_all_algorithms(by: :price, order: :asc)
    comparator = create_comparator(by, order)
    results = {}

    @sort_strategies.each do |name, strategy|
      time = Benchmark.realtime do
        strategy.sort(@products, &comparator)
      end
      results[name] = time
    end

    results
  end

  private

  def create_comparator(attribute, order)
    lambda do |a, b|
      result = a.send(attribute) <=> b.send(attribute)
      order == :desc ? -result : result
    end
  end

  def select_strategy(size)
    # データ量に応じて最適なアルゴリズムを選択
    if size < 10
      @sort_strategies[:insertion_sort]  # 小規模データでは挿入ソートが効率的
    elsif size < 1000
      @sort_strategies[:quick_sort]      # 中規模データではクイックソート
    else
      @sort_strategies[:merge_sort] # 大規模データではマージソート（安定性重視）
    end
  end
end

# テスト
if __FILE__ == $0
  manager = InventoryManager.new

  # テストデータの生成
  products_data = [
    ['ノートPC', 120_000, 5, '電子機器', Time.now],
    ['マウス', 3000, 50, '周辺機器', Time.now - 86_400],
    ['キーボード', 8000, 20, '周辺機器', Time.now - 3600],
    ['モニター', 45_000, 8, '電子機器', Time.now - 7200],
    ['USBメモリ', 2000, 100, '記憶装置', Time.now - 172_800],
    ['外付けHDD', 12_000, 15, '記憶装置', Time.now - 43_200],
    ['Webカメラ', 5000, 30, '周辺機器', Time.now - 14_400],
    ['スピーカー', 15_000, 12, '音響機器', Time.now - 28_800]
  ]

  products_data.each do |data|
    manager.add_product(*data)
  end

  puts '=== 価格順ソート（降順） ==='
  sorted = manager.sort_products(by: :price, order: :desc)
  sorted.each { |p| puts p }

  puts "\n=== 在庫数順ソート（昇順） ==="
  sorted = manager.sort_products(by: :stock, order: :asc)
  sorted.each { |p| puts p }

  puts "\n=== カスタムソート（在庫少ない順、同じなら価格高い順） ==="
  sorted = manager.sort_products do |a, b|
    comp = a.stock <=> b.stock
    comp == 0 ? b.price <=> a.price : comp
  end
  sorted.each { |p| puts p }

  puts "\n=== パフォーマンス測定 ==="
  result = manager.sort_with_benchmark(by: :price)
  puts "アルゴリズム: #{result[:algorithm]}"
  puts "処理時間: #{'%.6f' % result[:time]}秒"
  puts "データ数: #{result[:count]}件"

  puts "\n=== 全アルゴリズムのベンチマーク ==="
  benchmarks = manager.benchmark_all_algorithms(by: :price)
  benchmarks.each do |algo, time|
    puts "#{algo}: #{'%.6f' % time}秒"
  end
end
