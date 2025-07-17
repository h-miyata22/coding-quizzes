require 'digest'
require 'set'

class BloomFilter
  attr_reader :size, :hash_count, :bit_array, :items_count

  def initialize(expected_items:, false_positive_rate: 0.01)
    @expected_items = expected_items
    @false_positive_rate = false_positive_rate

    # 最適なサイズとハッシュ関数の数を計算
    @size = calculate_optimal_size(expected_items, false_positive_rate)
    @hash_count = calculate_optimal_hash_count(@size, expected_items)

    @bit_array = Array.new(@size, false)
    @items_count = 0
  end

  def add(item)
    hash_values = calculate_hashes(item)

    hash_values.each do |hash_val|
      @bit_array[hash_val % @size] = true
    end

    @items_count += 1
  end

  def contains?(item)
    hash_values = calculate_hashes(item)

    hash_values.all? { |hash_val| @bit_array[hash_val % @size] }
  end

  def false_positive_probability
    # 実際の偽陽性率を計算
    # (1 - e^(-k*n/m))^k
    return 0.0 if @items_count == 0

    ratio = -@hash_count * @items_count.to_f / @size
    (1 - Math.exp(ratio))**@hash_count
  end

  def statistics
    filled_bits = @bit_array.count(true)

    {
      size: @size,
      hash_functions: @hash_count,
      items: @items_count,
      fill_rate: filled_bits.to_f / @size,
      expected_fpr: @false_positive_rate,
      actual_fpr: false_positive_probability.round(4),
      memory_usage: @size / 8 # バイト単位
    }
  end

  def merge(other)
    raise 'Incompatible Bloom filters' unless compatible?(other)

    merged = BloomFilter.new(
      expected_items: @expected_items + other.instance_variable_get(:@expected_items),
      false_positive_rate: @false_positive_rate
    )

    # ビット配列のOR演算
    @size.times do |i|
      merged.instance_variable_get(:@bit_array)[i] = @bit_array[i] || other.bit_array[i]
    end

    merged.instance_variable_set(:@items_count, @items_count + other.items_count)
    merged
  end

  private

  def calculate_optimal_size(n, p)
    # m = -n * ln(p) / (ln(2)^2)
    (-n * Math.log(p) / (Math.log(2)**2)).ceil
  end

  def calculate_optimal_hash_count(m, n)
    # k = (m/n) * ln(2)
    ((m.to_f / n) * Math.log(2)).round
  end

  def calculate_hashes(item)
    # 複数のハッシュ関数を生成（ダブルハッシング法）
    hash1 = Digest::MD5.hexdigest(item.to_s).to_i(16)
    hash2 = Digest::SHA256.hexdigest(item.to_s).to_i(16)

    Array.new(@hash_count) do |i|
      (hash1 + i * hash2) % @size
    end
  end

  def compatible?(other)
    @size == other.size && @hash_count == other.hash_count
  end
end

class CountingBloomFilter
  def initialize(expected_items:, false_positive_rate: 0.01, max_count: 15)
    @expected_items = expected_items
    @false_positive_rate = false_positive_rate
    @max_count = max_count

    # カウンタのビット数を決定（例: 4ビット = 最大15）
    @counter_bits = Math.log2(@max_count + 1).ceil

    # サイズとハッシュ関数の数を計算
    @size = calculate_optimal_size(expected_items, false_positive_rate)
    @hash_count = calculate_optimal_hash_count(@size, expected_items)

    @counters = Array.new(@size, 0)
    @items_count = 0
  end

  def add(item)
    hash_values = calculate_hashes(item)

    hash_values.each do |hash_val|
      index = hash_val % @size
      @counters[index] = [@counters[index] + 1, @max_count].min
    end

    @items_count += 1
  end

  def remove(item)
    return false unless contains?(item)

    hash_values = calculate_hashes(item)

    hash_values.each do |hash_val|
      index = hash_val % @size
      @counters[index] = [@counters[index] - 1, 0].max
    end

    @items_count = [@items_count - 1, 0].max
    true
  end

  def contains?(item)
    hash_values = calculate_hashes(item)

    hash_values.all? { |hash_val| @counters[hash_val % @size] > 0 }
  end

  def count_estimate(item)
    hash_values = calculate_hashes(item)

    # 最小カウントを返す（保守的な推定）
    hash_values.map { |hash_val| @counters[hash_val % @size] }.min
  end

  private

  def calculate_optimal_size(n, p)
    (-n * Math.log(p) / (Math.log(2)**2)).ceil
  end

  def calculate_optimal_hash_count(m, n)
    ((m.to_f / n) * Math.log(2)).round
  end

  def calculate_hashes(item)
    hash1 = Digest::MD5.hexdigest(item.to_s).to_i(16)
    hash2 = Digest::SHA256.hexdigest(item.to_s).to_i(16)

    Array.new(@hash_count) do |i|
      (hash1 + i * hash2) % @size
    end
  end
end

class HyperLogLog
  def initialize(precision: 14)
    @precision = precision
    @m = 2**precision # レジスタ数
    @registers = Array.new(@m, 0)
    @alpha = calculate_alpha(@m)
  end

  def add(item)
    hash = Digest::SHA256.hexdigest(item.to_s).to_i(16)

    # 最初のpビットでレジスタを選択
    register_index = hash >> (64 - @precision)

    # 残りのビットで最初の1の位置を見つける
    remaining_hash = hash & ((1 << (64 - @precision)) - 1)
    leading_zero_count = count_leading_zeros(remaining_hash) + 1

    # レジスタを更新
    @registers[register_index] = [@registers[register_index], leading_zero_count].max
  end

  def cardinality
    # HyperLogLogの基数推定式
    raw_estimate = @alpha * @m * @m / @registers.sum { |val| 2.0**-val }

    # 小さい値の補正
    if raw_estimate <= 2.5 * @m
      zeros = @registers.count(0)
      return @m * Math.log(@m.to_f / zeros) if zeros != 0
    end

    # 大きい値の補正
    if raw_estimate <= (1.0 / 30.0) * (1 << 32)
      raw_estimate
    else
      -(1 << 32) * Math.log(1 - raw_estimate / (1 << 32))
    end.round
  end

  def merge(other)
    raise 'Incompatible HyperLogLog' unless @m == other.instance_variable_get(:@m)

    merged = HyperLogLog.new(precision: @precision)
    merged_registers = merged.instance_variable_get(:@registers)

    @m.times do |i|
      merged_registers[i] = [@registers[i], other.instance_variable_get(:@registers)[i]].max
    end

    merged
  end

  private

  def calculate_alpha(m)
    case m
    when 16 then 0.673
    when 32 then 0.697
    when 64 then 0.709
    else 0.7213 / (1 + 1.079 / m)
    end
  end

  def count_leading_zeros(hash)
    return 64 if hash == 0

    count = 0
    mask = 1 << 63

    while (hash & mask) == 0 && count < 64
      count += 1
      mask >>= 1
    end

    count
  end
end

class MinHash
  def initialize(num_hashes: 128)
    @num_hashes = num_hashes
    @hash_functions = generate_hash_functions(num_hashes)
  end

  def calculate_signature(items)
    signature = Array.new(@num_hashes, Float::INFINITY)

    items.each do |item|
      @hash_functions.each_with_index do |hash_func, i|
        hash_val = hash_func.call(item)
        signature[i] = [signature[i], hash_val].min
      end
    end

    signature
  end

  def jaccard_similarity(signature1, signature2)
    raise 'Incompatible signatures' unless signature1.size == signature2.size

    matches = signature1.zip(signature2).count { |a, b| a == b }
    matches.to_f / signature1.size
  end

  private

  def generate_hash_functions(count)
    # 独立したハッシュ関数を生成
    Array.new(count) do |_i|
      a = rand(1..1_000_000)
      b = rand(1..1_000_000)
      c = 4_294_967_311 # 大きな素数

      ->(item) { (a * item.hash + b) % c }
    end
  end
end

class ProbabilisticSet
  def self.jaccard_similarity(set1, set2)
    # 正確なJaccard類似度の計算
    set1 = Set.new(set1)
    set2 = Set.new(set2)

    intersection = set1 & set2
    union = set1 | set2

    return 0.0 if union.empty?

    intersection.size.to_f / union.size
  end

  def self.estimate_jaccard_with_minhash(set1, set2, num_hashes: 128)
    minhash = MinHash.new(num_hashes: num_hashes)

    sig1 = minhash.calculate_signature(set1)
    sig2 = minhash.calculate_signature(set2)

    minhash.jaccard_similarity(sig1, sig2)
  end
end

# テスト
if __FILE__ == $0
  puts '=== Bloom Filter Test ==='
  bloom = BloomFilter.new(expected_items: 1000, false_positive_rate: 0.01)

  # 要素を追加
  words = %w[apple banana cherry date elderberry]
  words.each { |word| bloom.add(word) }

  # 存在確認
  test_words = words + %w[fig grape kiwi]
  test_words.each do |word|
    result = bloom.contains?(word)
    actual = words.include?(word)
    puts "#{word}: #{result} (actual: #{actual})"
  end

  puts "\nBloom Filter Statistics:"
  bloom.statistics.each { |k, v| puts "  #{k}: #{v}" }

  puts "\n=== Counting Bloom Filter Test ==="
  counting_bloom = CountingBloomFilter.new(expected_items: 100, false_positive_rate: 0.01)

  # 要素の追加と削除
  counting_bloom.add('test')
  counting_bloom.add('test') # 重複追加
  puts "Contains 'test': #{counting_bloom.contains?('test')}"
  puts "Count estimate for 'test': #{counting_bloom.count_estimate('test')}"

  counting_bloom.remove('test')
  puts "After one removal, contains 'test': #{counting_bloom.contains?('test')}"

  puts "\n=== HyperLogLog Test ==="
  hll = HyperLogLog.new(precision: 14)

  # 多数の要素を追加
  10_000.times { |i| hll.add("element_#{i}") }

  estimated = hll.cardinality
  actual = 10_000
  error = ((estimated - actual).abs / actual.to_f * 100).round(2)
  puts "Actual cardinality: #{actual}"
  puts "Estimated cardinality: #{estimated}"
  puts "Error rate: #{error}%"

  puts "\n=== MinHash Similarity Test ==="
  set1 = %w[apple banana cherry date elderberry]
  set2 = %w[banana cherry date fig grape]

  # 正確な類似度
  exact_similarity = ProbabilisticSet.jaccard_similarity(set1, set2)
  puts "Exact Jaccard similarity: #{exact_similarity.round(3)}"

  # MinHashによる推定
  estimated_similarity = ProbabilisticSet.estimate_jaccard_with_minhash(set1, set2, num_hashes: 128)
  puts "MinHash estimated similarity: #{estimated_similarity.round(3)}"

  # より大きなセットでテスト
  large_set1 = (1..1000).map { |i| "item_#{i}" }
  large_set2 = (500..1500).map { |i| "item_#{i}" }

  exact_large = ProbabilisticSet.jaccard_similarity(large_set1, large_set2)
  estimated_large = ProbabilisticSet.estimate_jaccard_with_minhash(large_set1, large_set2)

  puts "\nLarge sets (1000 items each, 501 common):"
  puts "Exact similarity: #{exact_large.round(3)}"
  puts "Estimated similarity: #{estimated_large.round(3)}"
end
