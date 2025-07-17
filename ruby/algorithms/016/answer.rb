require 'digest'
require 'set'

class CacheNode
  attr_reader :id, :capacity, :data, :virtual_nodes
  attr_accessor :status

  def initialize(id, capacity: 1000, virtual_nodes: 150)
    @id = id
    @capacity = capacity
    @virtual_nodes = virtual_nodes
    @data = {}
    @status = :active
  end

  def put(key, value)
    return false if @data.size >= @capacity && !@data.key?(key)

    @data[key] = value
    true
  end

  def get(key)
    @data[key]
  end

  def delete(key)
    @data.delete(key)
  end

  def size
    @data.size
  end

  def available_capacity
    @capacity - @data.size
  end

  def load_factor
    @data.size.to_f / @capacity
  end

  def active?
    @status == :active
  end

  def deactivate
    @status = :inactive
  end

  def activate
    @status = :active
  end
end

class ConsistentHash
  def initialize
    @ring = {} # ハッシュ値 => ノード
    @sorted_keys = []
    @nodes = {}
  end

  def add_node(node)
    @nodes[node.id] = node

    # 仮想ノードをリングに追加
    node.virtual_nodes.times do |i|
      virtual_node_id = "#{node.id}:#{i}"
      hash_value = hash_function(virtual_node_id)
      @ring[hash_value] = node
    end

    rebuild_sorted_keys
  end

  def remove_node(node_id)
    node = @nodes.delete(node_id)
    return unless node

    # 仮想ノードをリングから削除
    @ring.delete_if { |_, n| n.id == node_id }
    rebuild_sorted_keys

    node
  end

  def get_node(key)
    return nil if @ring.empty?

    hash_value = hash_function(key)

    # 二分探索で次のノードを見つける
    index = binary_search(hash_value)
    @ring[@sorted_keys[index]]
  end

  def get_nodes(key, count)
    return [] if @ring.empty?

    nodes = []
    seen_nodes = Set.new
    hash_value = hash_function(key)
    start_index = binary_search(hash_value)

    # リングを回って必要な数のユニークなノードを集める
    i = start_index
    while nodes.size < count && nodes.size < @nodes.size
      node = @ring[@sorted_keys[i]]

      if node.active? && !seen_nodes.include?(node.id)
        nodes << node
        seen_nodes.add(node.id)
      end

      i = (i + 1) % @sorted_keys.size
    end

    nodes
  end

  def get_all_nodes
    @nodes.values
  end

  def node_count
    @nodes.size
  end

  private

  def hash_function(key)
    Digest::MD5.hexdigest(key).to_i(16)
  end

  def rebuild_sorted_keys
    @sorted_keys = @ring.keys.sort
  end

  def binary_search(hash_value)
    return 0 if @sorted_keys.empty?

    left = 0
    right = @sorted_keys.size - 1

    while left <= right
      mid = (left + right) / 2

      if @sorted_keys[mid] == hash_value
        return mid
      elsif @sorted_keys[mid] < hash_value
        left = mid + 1
      else
        right = mid - 1
      end
    end

    # ラップアラウンドの処理
    left >= @sorted_keys.size ? 0 : left
  end
end

class DistributedCache
  def initialize(replication_factor: 2)
    @consistent_hash = ConsistentHash.new
    @replication_factor = replication_factor
    @stats = { hits: 0, misses: 0, puts: 0, migrations: 0 }
  end

  def add_node(node_id, capacity: 1000, virtual_nodes: 150)
    new_node = CacheNode.new(node_id, capacity: capacity, virtual_nodes: virtual_nodes)

    # 既存のデータを再配置
    migrate_data_to_new_node(new_node) if @consistent_hash.node_count > 0

    @consistent_hash.add_node(new_node)
  end

  def remove_node(node_id)
    node = @consistent_hash.remove_node(node_id)
    return unless node

    # データを他のノードに移行
    migrate_data_from_node(node)
  end

  def put(key, value)
    nodes = @consistent_hash.get_nodes(key, @replication_factor)
    return false if nodes.empty?

    success_count = 0
    nodes.each do |node|
      success_count += 1 if node.put(key, value)
    end

    @stats[:puts] += 1
    success_count > 0
  end

  def get(key)
    nodes = @consistent_hash.get_nodes(key, @replication_factor)

    nodes.each do |node|
      value = node.get(key)
      if value
        @stats[:hits] += 1
        return value
      end
    end

    @stats[:misses] += 1
    nil
  end

  def delete(key)
    nodes = @consistent_hash.get_nodes(key, @replication_factor)

    deleted = false
    nodes.each do |node|
      deleted = true if node.delete(key)
    end

    deleted
  end

  def load_distribution
    distribution = {}

    @consistent_hash.get_all_nodes.each do |node|
      distribution[node.id] = {
        size: node.size,
        capacity: node.capacity,
        load_factor: (node.load_factor * 100).round(2),
        status: node.status
      }
    end

    distribution
  end

  def statistics
    total_capacity = 0
    total_size = 0

    @consistent_hash.get_all_nodes.each do |node|
      total_capacity += node.capacity
      total_size += node.size
    end

    hit_rate = if @stats[:hits] + @stats[:misses] > 0
                 @stats[:hits].to_f / (@stats[:hits] + @stats[:misses])
               else
                 0
               end

    {
      nodes: @consistent_hash.node_count,
      total_capacity: total_capacity,
      total_size: total_size,
      utilization: (total_size.to_f / total_capacity * 100).round(2),
      hit_rate: (hit_rate * 100).round(2),
      puts: @stats[:puts],
      migrations: @stats[:migrations],
      replication_factor: @replication_factor
    }
  end

  def simulate_node_failure(node_id)
    nodes = @consistent_hash.get_all_nodes
    failed_node = nodes.find { |n| n.id == node_id }

    return false unless failed_node

    failed_node.deactivate

    # フェイルオーバーのシミュレーション
    # 実際のシステムでは、レプリケーションにより
    # データは既に他のノードに存在する
    true
  end

  def recover_node(node_id)
    nodes = @consistent_hash.get_all_nodes
    failed_node = nodes.find { |n| n.id == node_id }

    return false unless failed_node

    failed_node.activate
    true
  end

  private

  def migrate_data_to_new_node(new_node)
    # 簡易的な実装：実際のシステムではより効率的な方法を使用
    @consistent_hash.add_node(new_node)

    migration_count = 0

    @consistent_hash.get_all_nodes.each do |node|
      next if node.id == new_node.id

      keys_to_migrate = []

      node.data.keys.each do |key|
        # 新しいハッシュリングでの所属先を確認
        target_nodes = @consistent_hash.get_nodes(key, @replication_factor)

        # 新しいノードがレプリカの一つになる場合
        keys_to_migrate << key if target_nodes.include?(new_node) && !target_nodes.include?(node)
      end

      # データを移行
      keys_to_migrate.each do |key|
        value = node.get(key)
        new_node.put(key, value)
        migration_count += 1
      end
    end

    @stats[:migrations] += migration_count
    @consistent_hash.remove_node(new_node.id) # 一時的に削除（後で正式に追加）
  end

  def migrate_data_from_node(removed_node)
    migration_count = 0

    removed_node.data.each do |key, value|
      # 新しいレプリカ先を見つける
      nodes = @consistent_hash.get_nodes(key, @replication_factor)

      nodes.each do |node|
        if node.put(key, value)
          migration_count += 1
          break
        end
      end
    end

    @stats[:migrations] += migration_count
  end
end

# テスト
if __FILE__ == $0
  cache = DistributedCache.new(replication_factor: 2)

  puts '=== Adding Initial Nodes ==='
  cache.add_node('node1', capacity: 100)
  cache.add_node('node2', capacity: 100)
  cache.add_node('node3', capacity: 100)

  puts "\n=== Storing Data ==="
  # テストデータを格納
  100.times do |i|
    key = "user:#{i}"
    value = { id: i, name: "User#{i}", score: rand(100) }
    cache.put(key, value)
  end

  puts "\n=== Initial Load Distribution ==="
  distribution = cache.load_distribution
  distribution.each do |node_id, info|
    puts "#{node_id}: #{info[:size]} items (#{info[:load_factor]}% full)"
  end

  puts "\n=== Adding New Node ==="
  cache.add_node('node4', capacity: 100)

  puts "\n=== Load Distribution After Adding Node ==="
  distribution = cache.load_distribution
  distribution.each do |node_id, info|
    puts "#{node_id}: #{info[:size]} items (#{info[:load_factor]}% full)"
  end

  puts "\n=== Testing Data Retrieval ==="
  hits = 0
  10.times do |_i|
    key = "user:#{rand(100)}"
    value = cache.get(key)
    hits += 1 if value
  end
  puts "Retrieved #{hits}/10 random keys"

  puts "\n=== Simulating Node Failure ==="
  cache.simulate_node_failure('node2')

  # データアクセスのテスト
  accessible = 0
  100.times do |i|
    accessible += 1 if cache.get("user:#{i}")
  end
  puts "Accessible data after failure: #{accessible}/100"

  puts "\n=== System Statistics ==="
  stats = cache.statistics
  stats.each { |k, v| puts "#{k}: #{v}" }

  puts "\n=== Testing Consistent Hashing Distribution ==="
  # キーの分布を確認
  key_distribution = Hash.new(0)
  1000.times do |i|
    hash = ConsistentHash.new
    cache.instance_variable_get(:@consistent_hash).get_all_nodes.each { |n| hash.add_node(n) }
    node = hash.get_node("test_key_#{i}")
    key_distribution[node.id] += 1 if node
  end

  puts 'Key distribution (1000 keys):'
  key_distribution.each { |node_id, count| puts "  #{node_id}: #{count}" }
end
