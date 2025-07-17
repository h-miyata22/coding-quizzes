class CacheSystem
  def initialize(max_size: 100, ttl: 3600, eviction_policy: nil, logger: nil)
    @storage = CacheStorage.new(max_size: max_size)
    @eviction_policy = eviction_policy || LRUEvictionPolicy.new
    @ttl_manager = TTLManager.new(default_ttl: ttl)
    @statistics = CacheStatistics.new
    @logger = logger || NullLogger.new
  end

  def get(key, debug: false, &block)
    @logger.debug("[CACHE] Getting key: #{key}") if debug

    entry = fetch_valid_entry(key)

    if entry
      handle_hit(key, entry, debug)
    else
      handle_miss(key, debug, &block)
    end
  end

  def set(key, value, ttl: nil, debug: false)
    @logger.debug("[CACHE] Setting key: #{key}") if debug

    ensure_capacity unless @storage.contains?(key)

    entry = CacheEntry.new(value: value, ttl: ttl || @ttl_manager.default_ttl)
    @storage.store(key, entry)
    @eviction_policy.record_access(key)
  end

  def delete(key)
    result = @storage.remove(key)
    @eviction_policy.remove(key) if result
    result
  end

  def clear
    @storage.clear
    @eviction_policy.clear
    @statistics.reset
  end

  def size
    @storage.size
  end

  def stats
    @statistics.summary
  end

  def get_multiple(keys)
    BulkOperation.new(self).get_multiple(keys)
  end

  def set_multiple(entries)
    BulkOperation.new(self).set_multiple(entries)
  end

  private

  def fetch_valid_entry(key)
    entry = @storage.fetch(key)
    return nil unless entry

    if @ttl_manager.expired?(entry)
      invalidate(key)
      nil
    else
      entry
    end
  end

  def handle_hit(key, entry, debug)
    @statistics.record_hit
    @eviction_policy.record_access(key)
    @logger.debug("[CACHE HIT] Key: #{key}") if debug
    entry.value
  end

  def handle_miss(key, debug)
    @statistics.record_miss
    @logger.debug("[CACHE MISS] Key: #{key}") if debug

    return nil unless block_given?

    value = yield
    set(key, value, debug: debug)
    value
  end

  def ensure_capacity
    return unless @storage.at_capacity?

    key_to_evict = @eviction_policy.select_victim(@storage.keys)
    @storage.remove(key_to_evict) if key_to_evict
    @logger.debug("[CACHE EVICT] Key: #{key_to_evict}")
  end

  def invalidate(key)
    delete(key)
    @logger.debug("[CACHE EXPIRE] Key: #{key}")
  end
end

class CacheEntry
  attr_reader :value, :created_at, :accessed_at, :ttl

  def initialize(value:, ttl:)
    @value = value
    @ttl = ttl
    @created_at = Time.now
    @accessed_at = Time.now
  end

  def touch
    @accessed_at = Time.now
  end

  def age
    Time.now - @created_at
  end

  def idle_time
    Time.now - @accessed_at
  end
end

class CacheStorage
  def initialize(max_size:)
    @entries = {}
    @max_size = max_size
    @mutex = Mutex.new
  end

  def store(key, entry)
    @mutex.synchronize do
      @entries[key] = entry
    end
  end

  def fetch(key)
    @mutex.synchronize do
      entry = @entries[key]
      entry&.touch
      entry
    end
  end

  def remove(key)
    @mutex.synchronize do
      !@entries.delete(key).nil?
    end
  end

  def contains?(key)
    @entries.key?(key)
  end

  def clear
    @mutex.synchronize do
      @entries.clear
    end
  end

  def size
    @entries.size
  end

  def at_capacity?
    size >= @max_size
  end

  def keys
    @entries.keys
  end

  def each_entry(&block)
    @entries.each(&block)
  end
end

class TTLManager
  attr_reader :default_ttl

  def initialize(default_ttl:)
    @default_ttl = default_ttl
  end

  def expired?(entry)
    entry.age > entry.ttl
  end
end

class EvictionPolicy
  def record_access(key)
    raise NotImplementedError
  end

  def select_victim(keys)
    raise NotImplementedError
  end

  def remove(key)
    raise NotImplementedError
  end

  def clear
    raise NotImplementedError
  end
end

class LRUEvictionPolicy < EvictionPolicy
  def initialize
    @access_order = AccessOrderTracker.new
  end

  def record_access(key)
    @access_order.touch(key)
  end

  def select_victim(keys)
    @access_order.least_recently_used(keys)
  end

  def remove(key)
    @access_order.remove(key)
  end

  def clear
    @access_order.clear
  end
end

class AccessOrderTracker
  def initialize
    @access_times = {}
    @mutex = Mutex.new
  end

  def touch(key)
    @mutex.synchronize do
      @access_times[key] = Time.now
    end
  end

  def least_recently_used(keys)
    @mutex.synchronize do
      valid_times = @access_times.select { |k, _| keys.include?(k) }
      return nil if valid_times.empty?

      valid_times.min_by { |_, time| time }[0]
    end
  end

  def remove(key)
    @mutex.synchronize do
      @access_times.delete(key)
    end
  end

  def clear
    @mutex.synchronize do
      @access_times.clear
    end
  end
end

class CacheStatistics
  def initialize
    @hit_count = 0
    @miss_count = 0
    @mutex = Mutex.new
  end

  def record_hit
    @mutex.synchronize { @hit_count += 1 }
  end

  def record_miss
    @mutex.synchronize { @miss_count += 1 }
  end

  def reset
    @mutex.synchronize do
      @hit_count = 0
      @miss_count = 0
    end
  end

  def summary
    @mutex.synchronize do
      StatisticsSummary.new(
        hits: @hit_count,
        misses: @miss_count
      )
    end
  end
end

class StatisticsSummary
  attr_reader :hits, :misses

  def initialize(hits:, misses:)
    @hits = hits
    @misses = misses
  end

  def total_requests
    @hits + @misses
  end

  def hit_rate
    return 0.0 if total_requests == 0

    (@hits.to_f / total_requests * 100).round(2)
  end

  def to_s
    <<~STATS
      Cache Statistics:
        Hits: #{@hits}
        Misses: #{@misses}
        Hit Rate: #{hit_rate}%
    STATS
  end
end

class BulkOperation
  def initialize(cache)
    @cache = cache
  end

  def get_multiple(keys)
    keys.each_with_object({}) do |key, results|
      results[key] = @cache.get(key)
    end
  end

  def set_multiple(entries)
    entries.each do |key, value|
      @cache.set(key, value)
    end
  end
end

class Logger
  def debug(message)
    raise NotImplementedError
  end
end

class NullLogger < Logger
  def debug(message)
    # Do nothing
  end
end

class ConsoleLogger < Logger
  def debug(message)
    puts message
  end
end

# 追加の高度な機能

class FIFOEvictionPolicy < EvictionPolicy
  def initialize
    @insertion_order = []
    @mutex = Mutex.new
  end

  def record_access(key)
    @mutex.synchronize do
      @insertion_order.delete(key)
      @insertion_order << key
    end
  end

  def select_victim(keys)
    @mutex.synchronize do
      @insertion_order.find { |k| keys.include?(k) }
    end
  end

  def remove(key)
    @mutex.synchronize do
      @insertion_order.delete(key)
    end
  end

  def clear
    @mutex.synchronize do
      @insertion_order.clear
    end
  end
end

class SizeBasedEvictionPolicy < EvictionPolicy
  def initialize(size_calculator:)
    @size_calculator = size_calculator
    @sizes = {}
  end

  def record_access(key)
    # Size doesn't change on access
  end

  def select_victim(keys)
    # Evict the largest item
    keys.max_by { |k| @sizes[k] || 0 }
  end

  def remove(key)
    @sizes.delete(key)
  end

  def clear
    @sizes.clear
  end
end
