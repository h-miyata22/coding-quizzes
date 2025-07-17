
# 高度な文字列照合システムを実装してください。
# 複数のアルゴリズムを使用して、
# 効率的な文字列検索を実現します。
#
# 要件：
# 1. KMP（Knuth-Morris-Pratt）アルゴリズム
# 2. ボイヤー・ムーア法
# 3. ラビン・カープ法（ローリングハッシュ）
# 4. 複数パターンの同時検索
# 5. 近似文字列照合（編集距離を考慮）
# 6. パフォーマンス比較機能

# StringMatcher, PatternAnalyzer クラスを実装してください。

# 使用例:
# matcher = StringMatcher.new
# text = "ababcababa"
# pattern = "ababa"
# 
# # KMPアルゴリズムで検索
# result = matcher.kmp_search(text, pattern)
# # => { positions: [0, 6], count: 2, comparisons: 12 }
# 
# # 複数パターンの検索
# patterns = ["ab", "ba", "abc"]
# results = matcher.multi_pattern_search(text, patterns)
# # => { "ab" => [0, 2, 5, 7], "ba" => [1, 4, 8], "abc" => [2] }
# 
# # 近似照合（編集距離1以下）
# approx = matcher.approximate_search(text, "abaca", max_distance: 1)
# # => [{ position: 0, distance: 1 }, { position: 6, distance: 1 }]
