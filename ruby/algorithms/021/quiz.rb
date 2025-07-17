
# 配列の部分列に関する様々な問題を解くシステムを実装してください。
# 動的計画法と効率的なデータ構造を使用して、
# 最適解を求めます。
#
# 要件：
# 1. 最長増加部分列（LIS）の長さと実際の部分列
# 2. 最大部分配列和（カダネのアルゴリズム）
# 3. 最長共通部分列（LCS）
# 4. 部分列の個数カウント
# 5. 条件付き部分列の探索
# 6. 効率的な更新と照会

# SubsequenceSolver, DPTable クラスを実装してください。

# 使用例:
# solver = SubsequenceSolver.new
# 
# # 最長増加部分列
# arr = [10, 9, 2, 5, 3, 7, 101, 18]
# lis = solver.longest_increasing_subsequence(arr)
# # => { length: 4, sequence: [2, 3, 7, 101] }
# 
# # 最大部分配列和
# arr2 = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
# max_sum = solver.max_subarray_sum(arr2)
# # => { sum: 6, start: 3, end: 6, subarray: [4, -1, 2, 1] }
# 
# # 最長共通部分列
# lcs = solver.longest_common_subsequence("ABCDGH", "AEDFHR")
# # => { length: 3, sequence: "ADH" }
