
# プロジェクト管理のためのタスクスケジューリングシステムを実装してください。
# タスクには依存関係があり、適切な順序で実行する必要があります。
#
# 要件：
# 1. タスクと依存関係の管理
# 2. 実行可能な順序の計算（トポロジカルソート）
# 3. 循環依存の検出
# 4. 並列実行可能なタスクの識別
# 5. クリティカルパス（最長経路）の計算
# 6. タスクの推定完了時間の計算

# Task, TaskScheduler クラスを実装してください。

# 使用例:
# scheduler = TaskScheduler.new
# 
# # タスクを追加（名前、所要時間）
# scheduler.add_task("A", duration: 3)
# scheduler.add_task("B", duration: 2)
# scheduler.add_task("C", duration: 4)
# scheduler.add_task("D", duration: 1)
# 
# # 依存関係を追加（Bを実行するにはAが完了している必要がある）
# scheduler.add_dependency("B", "A")
# scheduler.add_dependency("C", "A")
# scheduler.add_dependency("D", "B")
# scheduler.add_dependency("D", "C")
# 
# # 実行順序を取得
# order = scheduler.get_execution_order
# # => ["A", "B", "C", "D"]
# 
# # 並列実行可能なタスクグループ
# parallel_groups = scheduler.get_parallel_groups
# # => [["A"], ["B", "C"], ["D"]]
# 
# # プロジェクト全体の最短完了時間
# min_time = scheduler.calculate_minimum_completion_time
# # => 8
