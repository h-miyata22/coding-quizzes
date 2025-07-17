
# あるゲーム会社では、プレイヤーのランキングシステムを実装したいと考えています。
# プレイヤーはスコアと最終プレイ時刻を持ち、以下の優先順位でランキングされます：
# 1. スコアが高い順
# 2. スコアが同じ場合は、最終プレイ時刻が新しい順

# 以下の要件を満たすランキングシステムを実装してください：
# - プレイヤーを追加できる
# - トップ N 人のプレイヤーを取得できる
# - 最低スコアのプレイヤーを効率的に削除できる
# - プレイヤー数を取得できる

# Player構造体とRankingSystemクラスを実装してください。

# 使用例:
# ranking = RankingSystem.new
# ranking.add_player("Alice", 1000, Time.now)
# ranking.add_player("Bob", 1200, Time.now - 3600)
# ranking.add_player("Charlie", 1200, Time.now)
# 
# top_players = ranking.get_top_players(2)
# # => [Player(name: "Charlie", score: 1200), Player(name: "Bob", score: 1200)]
# 
# ranking.remove_lowest_scorer
# # => Aliceが削除される
# 
# ranking.player_count
# # => 2
