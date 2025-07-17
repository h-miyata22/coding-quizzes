
# オンラインショップの商品在庫管理システムを実装してください。
# 商品は様々な条件でソートする必要があり、データ量に応じて
# 最適なソートアルゴリズムを選択できるようにしたいです。
#
# 要件：
# 1. 商品は名前、価格、在庫数、カテゴリ、最終更新日を持つ
# 2. 複数のソートアルゴリズムを実装（クイックソート、マージソート、挿入ソート）
# 3. ソート条件を動的に変更できる（価格順、在庫数順、更新日順など）
# 4. データ量に応じて適切なアルゴリズムを自動選択
# 5. ソートのパフォーマンスを測定できる

# Product, SortStrategy, InventoryManager クラスを実装してください。

# 使用例:
# manager = InventoryManager.new
# 
# manager.add_product("ノートPC", 80000, 5, "電子機器", Time.now)
# manager.add_product("マウス", 3000, 50, "周辺機器", Time.now - 86400)
# manager.add_product("キーボード", 8000, 20, "周辺機器", Time.now - 3600)
# 
# # 価格でソート（降順）
# sorted = manager.sort_products(by: :price, order: :desc)
# 
# # カスタム条件でソート（在庫が少ない順、同じなら価格が高い順）
# sorted = manager.sort_products do |a, b|
#   comp = a.stock <=> b.stock
#   comp == 0 ? b.price <=> a.price : comp
# end
# 
# # パフォーマンス測定付きソート
# result = manager.sort_with_benchmark(by: :price)
# # => { products: [...], algorithm: "quick_sort", time: 0.001 }
