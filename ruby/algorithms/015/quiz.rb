
# リアルタイムセンサーデータのストリーム処理システムを実装してください。
# 大量のデータストリームから異常を検出し、
# 統計情報をリアルタイムで計算します。
#
# 要件：
# 1. スライディングウィンドウによるデータ管理（時間/個数ベース）
# 2. オンラインでの統計計算（平均、分散、中央値）
# 3. 異常値検出（統計的手法、変化点検出）
# 4. メモリ効率的なデータ構造
# 5. 複数のメトリクスの同時追跡
# 6. アラート機能（閾値超過、急激な変化）

# DataPoint, StreamProcessor, SlidingWindow クラスを実装してください。

# 使用例:
# processor = StreamProcessor.new(window_size: 100, time_window: 60)
# 
# # 異常検出ルールを設定
# processor.add_rule(:high_value, threshold: 100)
# processor.add_rule(:rapid_change, change_rate: 0.5)
# 
# # データストリームの処理
# processor.process(DataPoint.new(value: 25.5, timestamp: Time.now))
# processor.process(DataPoint.new(value: 26.1, timestamp: Time.now + 1))
# processor.process(DataPoint.new(value: 150.0, timestamp: Time.now + 2))
# 
# # 統計情報を取得
# stats = processor.get_statistics
# # => { mean: 67.2, median: 26.1, std_dev: 58.4, count: 3 }
# 
# # アラートを確認
# alerts = processor.get_alerts
# # => [{ type: :high_value, value: 150.0, timestamp: ... }]
