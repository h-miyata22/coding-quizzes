
# SNSのフォロー関係を分析するシステムを実装してください。
# ユーザー間のフォロー関係をグラフとして表現し、
# 様々な分析機能を提供します。
#
# 要件：
# 1. ユーザーの追加とフォロー関係の管理
# 2. 相互フォローの検出
# 3. あるユーザーからN次の繋がりまでのユーザーを探索
# 4. 最も影響力のあるユーザー（フォロワー数が多い）を検出
# 5. 2人のユーザー間の最短経路を探索
# 6. 閉じたコミュニティ（全員が相互フォロー）を検出

# SocialNetwork, User クラスを実装してください。

# 使用例:
# network = SocialNetwork.new
# 
# network.add_user("Alice")
# network.add_user("Bob")
# network.add_user("Charlie")
# network.add_user("David")
# 
# network.follow("Alice", "Bob")
# network.follow("Bob", "Alice")
# network.follow("Bob", "Charlie")
# network.follow("Charlie", "David")
# 
# # 相互フォローを検出
# mutual = network.find_mutual_follows("Bob")
# # => ["Alice"]
# 
# # N次の繋がりを探索
# connections = network.find_connections("Alice", depth: 2)
# # => { 1 => ["Bob"], 2 => ["Charlie"] }
# 
# # 最短経路を探索
# path = network.shortest_path("Alice", "David")
# # => ["Alice", "Bob", "Charlie", "David"]
