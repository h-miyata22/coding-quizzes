require 'time'

class CacheNode
  attr_accessor :key, :value, :prev, :next, :accessed_at, :expires_at, :size

  def initialize(key, value, ttl = nil)
    @key = key
    @value = value
    @prev = nil
    @next = nil
    @accessed_at = Time.now
    @expires_at = ttl ? Time.now + ttl : nil
    @size = estimate_size(value)
  end

  def expired?
    @expires_at && Time.now > @expires_at
  end

  def touch
    @accessed_at = Time.now
  end

  private

  def estimate_size(value)
    # 簡易的なメモリサイズ推定
    case value
    when String
      value.bytesize + 40 # 文字列のバイト数 + オブジェクトのオーバーヘッド
    when Hash
      size = 40  # Hashオブジェクトのオーバーヘッド
      value.each do |k, v|
        size += estimate_size(k) + estimate_size(v)
      end
      size
    when Array
      size = 40  # Arrayオブジェクトのオーバーヘッド
      value.each { |item| size += estimate_size(item) }
      size
    when Numeric
      8
    else
      64 # デフォルトのオブジェクトサイズ
    end
  end
end

class LRUCache
  def initialize(capacity:, ttl: nil, max_memory: nil)
    @capacity = capacity
    @ttl = ttl
    @max_memory = max_memory
    @cache = {}
    @head = CacheNode.new(nil, nil)  # ダミーヘッド
    @tail = CacheNode.new(nil, nil)  # ダミーテール
    @head.next = @tail
    @tail.prev = @head
    @current_memory = 0
    @stats = { hits: 0, misses: 0, evictions: 0 }
  end

  def put(key, value)
    # 既存のエントリを削除
    if @cache.key?(key)
      remove_node(@cache[key])
      @current_memory -= @cache[key].size
    end

    # 新しいノードを作成
    node = CacheNode.new(key, value, @ttl)

    # メモリ制限チェック
    evict_until_memory_available(node.size) if @max_memory && @current_memory + node.size > @max_memory

    # 容量制限チェック
    evict_lru if @cache.size >= @capacity && !@cache.empty?

    # ノードを追加
    @cache[key] = node
    @current_memory += node.size
    add_to_head(node)
  end

  def get(key)
    node = @cache[key]

    if node.nil?
      @stats[:misses] += 1
      return nil
    end

    # 有効期限チェック
    if node.expired?
      delete(key)
      @stats[:misses] += 1
      return nil
    end

    @stats[:hits] += 1

    # ノードを先頭に移動（最近使用）
    remove_node(node)
    add_to_head(node)
    node.touch

    node.value
  end

  def delete(key)
    node = @cache[key]
    return false unless node

    remove_node(node)
    @cache.delete(key)
    @current_memory -= node.size
    true
  end

  def delete_by_pattern(pattern)
    deleted_count = 0
    keys_to_delete = @cache.keys.select { |key| key.match?(pattern) }

    keys_to_delete.each do |key|
      deleted_count += 1 if delete(key)
    end

    deleted_count
  end

  def clear
    @cache.clear
    @head.next = @tail
    @tail.prev = @head
    @current_memory = 0
    @stats[:evictions] += @cache.size
  end

  def size
    @cache.size
  end

  def memory_usage
    @current_memory
  end

  def stats
    hit_rate = if @stats[:hits] + @stats[:misses] > 0
                 @stats[:hits].to_f / (@stats[:hits] + @stats[:misses])
               else
                 0.0
               end

    {
      hits: @stats[:hits],
      misses: @stats[:misses],
      evictions: @stats[:evictions],
      hit_rate: hit_rate.round(3),
      size: @cache.size,
      memory_usage: @current_memory,
      capacity: @capacity,
      max_memory: @max_memory
    }
  end

  def cleanup_expired
    expired_keys = []

    @cache.each do |key, node|
      expired_keys << key if node.expired?
    end

    expired_keys.each { |key| delete(key) }
    expired_keys.size
  end

  private

  def add_to_head(node)
    node.prev = @head
    node.next = @head.next
    @head.next.prev = node
    @head.next = node
  end

  def remove_node(node)
    node.prev.next = node.next
    node.next.prev = node.prev
  end

  def evict_lru
    lru_node = @tail.prev
    return if lru_node == @head

    remove_node(lru_node)
    @cache.delete(lru_node.key)
    @current_memory -= lru_node.size
    @stats[:evictions] += 1
  end

  def evict_until_memory_available(required_memory)
    evict_lru while @current_memory + required_memory > @max_memory && @tail.prev != @head
  end
end

# テスト
if __FILE__ == $0
  # 基本的なLRUキャッシュ
  puts '=== Basic LRU Cache ==='
  cache = LRUCache.new(capacity: 3)

  cache.put('A', 'Apple')
  cache.put('B', 'Banana')
  cache.put('C', 'Cherry')

  puts "Get A: #{cache.get('A')}" # Aが最近使用に

  cache.put('D', 'Date') # Bがエビクト
  puts "Get B: #{cache.get('B')}"  # nil
  puts "Get D: #{cache.get('D')}"  # Date

  puts "\nCache contents:"
  %w[A C D].each do |key|
    puts "  #{key}: #{cache.get(key)}"
  end

  # TTL付きキャッシュ
  puts "\n=== TTL Cache ==="
  ttl_cache = LRUCache.new(capacity: 10, ttl: 0.1) # 0.1秒のTTL

  ttl_cache.put('temp', 'Temporary data')
  puts "Immediate get: #{ttl_cache.get('temp')}"

  sleep(0.2)
  puts "After 0.2s: #{ttl_cache.get('temp')}" # nil (expired)

  # メモリ制限付きキャッシュ
  puts "\n=== Memory Limited Cache ==="
  mem_cache = LRUCache.new(capacity: 100, max_memory: 500)

  mem_cache.put('small', 'x')
  mem_cache.put('medium', 'x' * 50)
  mem_cache.put('large', { data: ['item'] * 10 })

  puts "Memory usage: #{mem_cache.memory_usage} bytes"

  # パターン削除
  puts "\n=== Pattern Deletion ==="
  pattern_cache = LRUCache.new(capacity: 10)

  pattern_cache.put('user:1', 'Alice')
  pattern_cache.put('user:2', 'Bob')
  pattern_cache.put('post:1', 'Hello')
  pattern_cache.put('post:2', 'World')

  deleted = pattern_cache.delete_by_pattern(/^user:/)
  puts "Deleted #{deleted} user entries"

  # 統計情報
  puts "\n=== Cache Statistics ==="
  stats_cache = LRUCache.new(capacity: 3)

  # データを追加してアクセス
  stats_cache.put('X', 100)
  stats_cache.put('Y', 200)
  stats_cache.put('Z', 300)

  stats_cache.get('X')  # hit
  stats_cache.get('Y')  # hit
  stats_cache.get('W')  # miss

  stats_cache.put('W', 400) # Zがエビクト

  stats = stats_cache.stats
  puts "Stats: #{stats}"
end
