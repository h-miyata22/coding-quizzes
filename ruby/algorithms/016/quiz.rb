
# 分散キャッシュシステムを実装してください。
# コンシステントハッシングを使用して、
# ノードの追加・削除時のデータ移動を最小化します。
#
# 要件：
# 1. コンシステントハッシング（仮想ノード付き）
# 2. ノードの動的な追加・削除
# 3. データのレプリケーション（冗長性）
# 4. 負荷分散の統計情報
# 5. ノード障害時の自動フェイルオーバー
# 6. データ移行の最小化

# CacheNode, ConsistentHash, DistributedCache クラスを実装してください。

# 使用例:
# cache = DistributedCache.new(replication_factor: 2)
# 
# # ノードを追加
# cache.add_node("node1", capacity: 1000)
# cache.add_node("node2", capacity: 1000)
# cache.add_node("node3", capacity: 1000)
# 
# # データを格納
# cache.put("user:123", { name: "Alice", age: 30 })
# cache.put("user:456", { name: "Bob", age: 25 })
# 
# # データを取得
# data = cache.get("user:123")
# # => { name: "Alice", age: 30 }
# 
# # ノードを追加（データの再配置が発生）
# cache.add_node("node4", capacity: 1000)
# 
# # 負荷分散統計
# stats = cache.load_distribution
# # => { "node1" => 245, "node2" => 251, "node3" => 248, "node4" => 256 }
