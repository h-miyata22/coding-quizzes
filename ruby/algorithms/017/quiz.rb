
# ドキュメント検索エンジンの転置インデックスシステムを実装してください。
# 効率的な全文検索と関連性スコアリングを実現します。
#
# 要件：
# 1. 転置インデックスの構築（単語→ドキュメントリスト）
# 2. TF-IDF（単語頻度-逆文書頻度）によるスコアリング
# 3. ブーリアン検索（AND, OR, NOT）のサポート
# 4. フレーズ検索（連続する単語の検索）
# 5. 検索結果のランキング
# 6. インデックスの圧縮と最適化

# Document, InvertedIndex, SearchEngine クラスを実装してください。

# 使用例:
# engine = SearchEngine.new
# 
# # ドキュメントを追加
# engine.add_document("doc1", "Ruby is a programming language")
# engine.add_document("doc2", "Ruby programming is fun")
# engine.add_document("doc3", "I love Ruby and Python programming")
# 
# # 単語検索
# results = engine.search("Ruby")
# # => [["doc1", 0.8], ["doc2", 0.8], ["doc3", 0.7]]
# 
# # ブーリアン検索
# results = engine.boolean_search("Ruby AND programming")
# # => ["doc2", "doc3"]
# 
# # フレーズ検索
# results = engine.phrase_search("Ruby programming")
# # => ["doc2"]
