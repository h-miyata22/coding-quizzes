
# 高性能なキャッシュシステムを実装してください。
# LRU（Least Recently Used）アルゴリズムを使用し、
# 様々な最適化機能を提供します。
#
# 要件：
# 1. O(1)でのget/put操作を実現
# 2. LRUによる自動的なエビクション（追い出し）
# 3. TTL（Time To Live）によるエントリの有効期限管理
# 4. キャッシュヒット率などの統計情報
# 5. 特定のパターンに基づくエントリの一括削除
# 6. メモリ使用量の監視と制限

# CacheNode, LRUCache クラスを実装してください。

# 使用例:
# cache = LRUCache.new(capacity: 3, ttl: 60)
# 
# cache.put("user:1", { name: "Alice", age: 30 })
# cache.put("user:2", { name: "Bob", age: 25 })
# cache.put("user:3", { name: "Charlie", age: 35 })
# 
# # キャッシュヒット
# user = cache.get("user:1")
# # => { name: "Alice", age: 30 }
# 
# # 新しいエントリを追加（user:2がエビクト）
# cache.put("user:4", { name: "David", age: 28 })
# 
# # 統計情報
# stats = cache.stats
# # => { hits: 1, misses: 0, hit_rate: 1.0, size: 3 }
# 
# # パターンによる削除
# cache.delete_by_pattern(/^user:/)
# # => 3 (削除されたエントリ数)
