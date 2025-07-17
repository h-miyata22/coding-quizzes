class Employee
  attr_reader :name, :skills

  def initialize(name, skills)
    @name = name
    @skills = skills
  end

  def skill_match_score(required_skills)
    score = 0
    match_count = 0

    required_skills.each do |skill, required_level|
      if @skills[skill]
        # スキルレベルが要求を満たしている場合のスコア
        if @skills[skill] >= required_level
          score += @skills[skill]
          match_count += 1
        else
          # 要求を満たさない場合はペナルティ
          score += @skills[skill] * 0.5
        end
      end
    end

    # 全ての要求スキルを満たしていない場合は大幅減点
    return 0 if match_count < required_skills.size

    score
  end
end

class Project
  attr_reader :name, :required_skills, :priority

  def initialize(name, required_skills, priority: 1)
    @name = name
    @required_skills = required_skills
    @priority = priority
  end
end

class TaskAssignment
  def initialize
    @employees = []
    @projects = []
    @cost_matrix = nil
  end

  def add_employee(name, skills)
    @employees << Employee.new(name, skills)
  end

  def add_project(name, required_skills, priority: 1)
    @projects << Project.new(name, required_skills, priority: priority)
  end

  def find_optimal_assignment
    build_cost_matrix

    # ハンガリアン法による最適割り当て
    assignment_indices = hungarian_algorithm

    # 結果の構築
    build_assignment_result(assignment_indices)
  end

  def find_all_optimal_assignments
    build_cost_matrix

    # 最適値を見つける
    optimal_indices = hungarian_algorithm
    optimal_value = calculate_total_score(optimal_indices)

    # 全ての可能な割り当てを探索
    all_assignments = []
    find_all_assignments_with_score([], 0, optimal_value, all_assignments)

    all_assignments
  end

  def assignment_fairness_score(assignments)
    return 1.0 if assignments.empty?

    # 各社員の満足度を計算
    satisfaction_scores = []

    assignments.each do |employee_name, project_name|
      employee = @employees.find { |e| e.name == employee_name }
      project = @projects.find { |p| p.name == project_name }

      next unless employee && project

      max_possible = employee.skills.values.sum
      actual = employee.skill_match_score(project.required_skills)
      satisfaction_scores << actual.to_f / max_possible
    end

    # 標準偏差が小さいほど公平
    mean = satisfaction_scores.sum / satisfaction_scores.size
    variance = satisfaction_scores.sum { |s| (s - mean)**2 } / satisfaction_scores.size
    std_dev = Math.sqrt(variance)

    # 公平性スコア（0〜1、1が最も公平）
    1.0 - [std_dev, 1.0].min
  end

  private

  def build_cost_matrix
    # コスト行列を構築（スコアを最大化したいので負の値を使用）
    n = [@employees.size, @projects.size].max
    @cost_matrix = Array.new(n) { Array.new(n, 0) }

    @employees.each_with_index do |employee, i|
      @projects.each_with_index do |project, j|
        score = employee.skill_match_score(project.required_skills)
        # 優先度を考慮
        weighted_score = score * project.priority
        # 最大化問題を最小化問題に変換
        @cost_matrix[i][j] = -weighted_score
      end
    end
  end

  def hungarian_algorithm
    n = @cost_matrix.size
    # コスト行列のコピーを作成
    matrix = @cost_matrix.map(&:dup)

    # ステップ1: 各行の最小値を引く
    matrix.each do |row|
      min_val = row.min
      row.map! { |val| val - min_val }
    end

    # ステップ2: 各列の最小値を引く
    n.times do |j|
      min_val = matrix.map { |row| row[j] }.min
      matrix.each { |row| row[j] -= min_val }
    end

    # ステップ3-5: 最適割り当てを見つける
    assignment = Array.new(n, -1)

    loop do
      # 0の位置を見つけて割り当てを試みる
      marked_rows = Array.new(n, false)
      marked_cols = Array.new(n, false)

      break if try_assignment(matrix, assignment, marked_rows, marked_cols)

      # 最小のカバーされていない要素を見つける
      min_uncovered = Float::INFINITY
      n.times do |i|
        n.times do |j|
          min_uncovered = [min_uncovered, matrix[i][j]].min if !marked_rows[i] && !marked_cols[j]
        end
      end

      # 行列を更新
      n.times do |i|
        n.times do |j|
          if marked_rows[i] && marked_cols[j]
            matrix[i][j] += min_uncovered
          elsif !marked_rows[i] && !marked_cols[j]
            matrix[i][j] -= min_uncovered
          end
        end
      end
    end

    assignment
  end

  def try_assignment(matrix, assignment, _marked_rows, _marked_cols)
    n = matrix.size

    # 単純な貪欲割り当て
    assignment.fill(-1)
    used_cols = Array.new(n, false)

    n.times do |i|
      n.times do |j|
        next unless matrix[i][j] == 0 && !used_cols[j]

        assignment[i] = j
        used_cols[j] = true
        break
      end
    end

    # 完全な割り当てができたかチェック
    assignment.count { |a| a >= 0 } == [@employees.size, @projects.size].min
  end

  def build_assignment_result(assignment_indices)
    assignments = []
    unassigned_employees = []
    unassigned_projects = []
    total_score = 0

    @employees.each_with_index do |employee, i|
      if i < assignment_indices.size && assignment_indices[i] >= 0 && assignment_indices[i] < @projects.size
        project = @projects[assignment_indices[i]]
        assignments << [employee.name, project.name]
        score = employee.skill_match_score(project.required_skills) * project.priority
        total_score += score
      else
        unassigned_employees << employee.name
      end
    end

    # 割り当てられなかったプロジェクト
    assigned_project_indices = assignment_indices[0...@employees.size].select { |i| i >= 0 }
    @projects.each_with_index do |project, j|
      unassigned_projects << project.name unless assigned_project_indices.include?(j)
    end

    {
      assignments: assignments,
      total_score: total_score,
      unassigned_employees: unassigned_employees,
      unassigned_projects: unassigned_projects,
      fairness_score: assignment_fairness_score(assignments)
    }
  end

  def calculate_total_score(assignment_indices)
    total = 0
    @employees.each_with_index do |employee, i|
      next unless i < assignment_indices.size && assignment_indices[i] >= 0 && assignment_indices[i] < @projects.size

      project = @projects[assignment_indices[i]]
      score = employee.skill_match_score(project.required_skills) * project.priority
      total += score
    end
    total
  end

  def find_all_assignments_with_score(current_assignment, emp_index, target_score, all_assignments)
    if emp_index == @employees.size
      all_assignments << current_assignment.dup if calculate_assignment_score(current_assignment) == target_score
      return
    end

    # 各プロジェクトへの割り当てを試す
    @projects.each_with_index do |_project, proj_index|
      # プロジェクトが既に割り当てられていないか確認
      next if current_assignment.any? { |_, p| p == proj_index }

      current_assignment << [emp_index, proj_index]
      find_all_assignments_with_score(current_assignment, emp_index + 1, target_score, all_assignments)
      current_assignment.pop
    end

    # この社員を割り当てない場合
    find_all_assignments_with_score(current_assignment, emp_index + 1, target_score, all_assignments)
  end

  def calculate_assignment_score(assignment)
    total = 0
    assignment.each do |emp_index, proj_index|
      employee = @employees[emp_index]
      project = @projects[proj_index]
      score = employee.skill_match_score(project.required_skills) * project.priority
      total += score
    end
    total
  end
end

# テスト
if __FILE__ == $0
  assignment = TaskAssignment.new

  # 社員を追加
  assignment.add_employee('Alice', { programming: 9, design: 5, management: 3 })
  assignment.add_employee('Bob', { programming: 6, design: 8, management: 7 })
  assignment.add_employee('Charlie', { programming: 7, design: 7, management: 5 })
  assignment.add_employee('David', { programming: 5, design: 6, management: 9 })

  # プロジェクトを追加
  assignment.add_project('Web App', { programming: 8, design: 5 }, priority: 3)
  assignment.add_project('Mobile App', { programming: 6, design: 8 }, priority: 2)
  assignment.add_project('Data Analysis', { programming: 7, management: 6 }, priority: 2)

  puts '=== Optimal Assignment ==='
  result = assignment.find_optimal_assignment

  puts 'Assignments:'
  result[:assignments].each do |emp, proj|
    puts "  #{emp} → #{proj}"
  end

  puts "\nTotal Score: #{result[:total_score]}"
  puts "Fairness Score: #{'%.2f' % result[:fairness_score]}"

  puts "\nUnassigned Employees: #{result[:unassigned_employees].join(', ')}" if result[:unassigned_employees].any?

  puts "Unassigned Projects: #{result[:unassigned_projects].join(', ')}" if result[:unassigned_projects].any?

  # スキルマッチの詳細
  puts "\n=== Skill Match Details ==="
  result[:assignments].each do |emp_name, proj_name|
    employee = assignment.instance_variable_get(:@employees).find { |e| e.name == emp_name }
    project = assignment.instance_variable_get(:@projects).find { |p| p.name == proj_name }

    next unless employee && project

    score = employee.skill_match_score(project.required_skills)
    puts "#{emp_name} → #{proj_name}:"
    puts "  Employee skills: #{employee.skills}"
    puts "  Required skills: #{project.required_skills}"
    puts "  Match score: #{score} (Priority: #{project.priority})"
  end
end
