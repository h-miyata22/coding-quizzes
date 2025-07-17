
# レストランの注文管理システムを実装してください。
# このシステムは以下の要件を満たす必要があります：
#
# 1. 注文は到着順（FIFO）で処理される
# 2. 各注文には優先度（通常/急ぎ）がある
# 3. 急ぎの注文は通常の注文より先に処理される
# 4. 同じ優先度の注文は到着順で処理される
# 5. 注文の状態が変わったときに、登録されたオブザーバーに通知する
# 6. 注文の処理時間を記録し、平均処理時間を計算できる

# Order, OrderQueue, OrderObserver クラスを実装してください。

# 使用例:
# queue = OrderQueue.new
# 
# # オブザーバーを登録
# kitchen_display = KitchenDisplay.new
# queue.add_observer(kitchen_display)
# 
# # 注文を追加
# queue.add_order("ハンバーガー", :normal)
# queue.add_order("サラダ", :urgent)
# queue.add_order("ポテト", :normal)
# 
# # 次の注文を処理（サラダが最初に処理される）
# order = queue.process_next_order
# # => Order(item: "サラダ", priority: :urgent)
# 
# # 平均処理時間を取得
# queue.average_processing_time
# # => 45.5 (秒)
