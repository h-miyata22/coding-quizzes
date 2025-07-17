
# 大量のログを効率的に処理するシステムを実装してください。
# 複数のログ生成源から並行してログを受信し、
# バッチ処理で効率的に処理します。
#
# 要件：
# 1. スレッドセーフなログキューの実装
# 2. 複数のプロデューサー（ログ生成）と単一のコンシューマー（ログ処理）
# 3. ログをバッチでまとめて処理（効率化のため）
# 4. ログレベル（ERROR, WARN, INFO）による優先度処理
# 5. バックプレッシャー対応（キューが満杯時の制御）
# 6. 処理統計の収集（処理数、平均処理時間など）

# LogEntry, LogQueue, LogProcessor クラスを実装してください。

# 使用例:
# processor = LogProcessor.new(batch_size: 10, max_queue_size: 100)
# 
# # ログプロデューサーを起動
# producer1 = Thread.new do
#   10.times do |i|
#     processor.add_log("Error #{i}", :error, "Service A")
#     sleep(0.01)
#   end
# end
# 
# producer2 = Thread.new do
#   20.times do |i|
#     processor.add_log("Info #{i}", :info, "Service B")
#     sleep(0.005)
#   end
# end
# 
# # ログ処理を開始
# processor.start_processing
# 
# # 統計情報を取得
# stats = processor.get_stats
# # => { processed: 30, avg_batch_size: 8.5, avg_process_time: 0.02 }
