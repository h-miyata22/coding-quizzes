
# Webサーバーのアクセスログを解析するシステムを実装してください。
# 様々なフォーマットのログから情報を抽出し、
# 統計情報を生成します。
#
# 要件：
# 1. 複数のログフォーマットに対応（Apache, Nginx, カスタム）
# 2. IPアドレス、日時、HTTPメソッド、パス、ステータスコードを抽出
# 3. 時間帯別、ステータスコード別の集計
# 4. 異常なアクセスパターンの検出（同一IPからの大量アクセスなど）
# 5. カスタムフィルタによる柔軟な検索
# 6. レポート生成機能

# LogParser, LogAnalyzer, AccessLog クラスを実装してください。

# 使用例:
# analyzer = LogAnalyzer.new
# 
# # ログを解析
# logs = [
#   '192.168.1.1 - - [10/Oct/2024:13:55:36 +0900] "GET /index.html HTTP/1.1" 200 2326',
#   '192.168.1.2 - - [10/Oct/2024:13:56:12 +0900] "POST /api/users HTTP/1.1" 201 156',
#   '192.168.1.1 - - [10/Oct/2024:13:56:45 +0900] "GET /favicon.ico HTTP/1.1" 404 209'
# ]
# 
# logs.each { |log| analyzer.add_log(log) }
# 
# # 統計情報を取得
# stats = analyzer.generate_stats
# # => { total: 3, by_status: {200=>1, 201=>1, 404=>1}, by_ip: {...} }
# 
# # 異常検出
# anomalies = analyzer.detect_anomalies(threshold: 10)
# # => [{ ip: "192.168.1.1", count: 15, type: :rapid_access }]
