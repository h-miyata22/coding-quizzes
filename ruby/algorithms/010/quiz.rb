
# 効率的な辞書システムを実装してください。
# 単語の追加・検索・削除に加えて、プレフィックス検索や
# ワイルドカード検索もサポートします。
#
# 要件：
# 1. Trieデータ構造を使用した効率的な実装
# 2. 単語の追加、削除、完全一致検索
# 3. プレフィックスから始まる全単語の取得
# 4. ワイルドカード（.）を含む検索（例: "c.t" → "cat", "cut"）
# 5. 単語の出現頻度管理
# 6. メモリ使用量の最適化

# TrieNode, Dictionary クラスを実装してください。

# 使用例:
# dict = Dictionary.new
# 
# # 単語を追加
# dict.add_word("cat", frequency: 10)
# dict.add_word("car", frequency: 15)
# dict.add_word("card", frequency: 5)
# dict.add_word("cut", frequency: 8)
# 
# # 検索
# dict.search("car")
# # => true
# 
# # プレフィックス検索
# words = dict.find_with_prefix("ca")
# # => ["cat", "car", "card"]
# 
# # ワイルドカード検索
# matches = dict.wildcard_search("c.t")
# # => ["cat", "cut"]
# 
# # 頻度順で取得
# top_words = dict.get_top_words_by_frequency(2)
# # => [["car", 15], ["cat", 10]]
