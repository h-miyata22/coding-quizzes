
# データベースの効率的なインデックスシステムを実装してください。
# B木（B-tree）を使用して、大量のデータに対する
# 高速な検索、挿入、削除を実現します。
#
# 要件：
# 1. B木の実装（次数3以上）
# 2. キーの挿入、削除、検索
# 3. 範囲検索（範囲内の全キーを取得）
# 4. 木の自動バランシング
# 5. ノードの分割とマージ
# 6. 統計情報（高さ、ノード数、充填率）

# BTreeNode, BTree クラスを実装してください。

# 使用例:
# btree = BTree.new(order: 3)  # 次数3のB木
# 
# # データの挿入
# btree.insert(10, "Data10")
# btree.insert(20, "Data20")
# btree.insert(5, "Data5")
# btree.insert(15, "Data15")
# 
# # 検索
# value = btree.search(15)
# # => "Data15"
# 
# # 範囲検索
# results = btree.range_search(8, 18)
# # => [[10, "Data10"], [15, "Data15"]]
# 
# # 統計情報
# stats = btree.statistics
# # => { height: 2, nodes: 3, keys: 4, fill_rate: 0.67 }
