
# テキストエディタの自動補完システムを実装してください。
# ユーザーが入力した文字列に対して、辞書から最も類似した単語を提案します。
#
# 要件：
# 1. 編集距離（レーベンシュタイン距離）を計算できる
# 2. 辞書内の全単語との距離を効率的に計算
# 3. 最も近い単語をN個提案できる
# 4. 前方一致する単語を優先的に提案
# 5. 計算結果をキャッシュして高速化

# EditDistance, AutoCompleteSystem クラスを実装してください。

# 使用例:
# dictionary = ["apple", "application", "apply", "banana", "band", "bandana"]
# system = AutoCompleteSystem.new(dictionary)
# 
# # 単語の提案（編集距離が近い順）
# suggestions = system.suggest("aple", limit: 3)
# # => ["apple", "apply", "application"]
# 
# # 前方一致を優先
# suggestions = system.suggest_with_prefix("app", limit: 3)
# # => ["apple", "application", "apply"]
# 
# # 編集距離の詳細を取得
# details = system.get_distance_details("aple", "apple")
# # => { distance: 1, operations: ["insert 'p' at position 2"] }
