
# 企業の人材配置最適化システムを実装してください。
# 社員とプロジェクトのマッチングを行い、
# 全体のパフォーマンスを最大化します。
#
# 要件：
# 1. 社員のスキルレベルとプロジェクトの要求レベルのマッチング
# 2. コスト（または利益）を考慮した最適割り当て
# 3. 制約条件（各社員は1プロジェクト、各プロジェクトは1人）
# 4. 部分マッチングも可能（全員が割り当てられない場合）
# 5. 割り当ての公平性スコア計算
# 6. 複数の最適解がある場合の列挙

# Employee, Project, TaskAssignment クラスを実装してください。

# 使用例:
# assignment = TaskAssignment.new
# 
# # 社員を追加（名前、スキル）
# assignment.add_employee("Alice", { programming: 8, design: 6 })
# assignment.add_employee("Bob", { programming: 6, design: 9 })
# assignment.add_employee("Charlie", { programming: 7, design: 7 })
# 
# # プロジェクトを追加（名前、要求スキル、重要度）
# assignment.add_project("Web App", { programming: 7, design: 5 }, priority: 3)
# assignment.add_project("Mobile App", { programming: 6, design: 8 }, priority: 2)
# 
# # 最適な割り当てを計算
# result = assignment.find_optimal_assignment
# # => { assignments: [["Alice", "Web App"], ["Bob", "Mobile App"]], 
# #      total_score: 85, unassigned_employees: ["Charlie"] }
