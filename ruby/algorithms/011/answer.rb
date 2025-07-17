require 'set'

class Task
  attr_reader :name, :duration
  attr_accessor :earliest_start, :earliest_finish, :latest_start, :latest_finish, :slack

  def initialize(name, duration)
    @name = name
    @duration = duration
    @earliest_start = 0
    @earliest_finish = 0
    @latest_start = Float::INFINITY
    @latest_finish = Float::INFINITY
    @slack = 0
  end

  def critical?
    @slack == 0
  end
end

class TaskScheduler
  def initialize
    @tasks = {}
    @dependencies = Hash.new { |h, k| h[k] = Set.new }
    @reverse_dependencies = Hash.new { |h, k| h[k] = Set.new }
  end

  def add_task(name, duration:)
    @tasks[name] = Task.new(name, duration)
  end

  def add_dependency(dependent, prerequisite)
    return false unless @tasks[dependent] && @tasks[prerequisite]

    @dependencies[dependent].add(prerequisite)
    @reverse_dependencies[prerequisite].add(dependent)

    # 循環依存のチェック
    if has_cycle?
      @dependencies[dependent].delete(prerequisite)
      @reverse_dependencies[prerequisite].delete(dependent)
      raise 'Circular dependency detected!'
    end

    true
  end

  def get_execution_order
    return [] if @tasks.empty?

    # トポロジカルソート using Kahn's algorithm
    in_degree = calculate_in_degrees
    queue = []
    result = []

    # 入次数0のタスクをキューに追加
    @tasks.keys.each do |task|
      queue.push(task) if in_degree[task] == 0
    end

    until queue.empty?
      current = queue.shift
      result << current

      # 依存するタスクの入次数を減らす
      @reverse_dependencies[current].each do |dependent|
        in_degree[dependent] -= 1
        queue.push(dependent) if in_degree[dependent] == 0
      end
    end

    result.length == @tasks.length ? result : []
  end

  def get_parallel_groups
    return [] if @tasks.empty?

    groups = []
    remaining = @tasks.keys.to_set
    in_degree = calculate_in_degrees

    until remaining.empty?
      # 現在実行可能なタスク（入次数0）を見つける
      current_group = []

      remaining.each do |task|
        current_group << task if in_degree[task] == 0
      end

      break if current_group.empty? # 循環依存がある場合

      groups << current_group.sort

      # 実行したタスクを削除し、依存関係を更新
      current_group.each do |task|
        remaining.delete(task)
        @reverse_dependencies[task].each do |dependent|
          in_degree[dependent] -= 1 if remaining.include?(dependent)
        end
      end
    end

    groups
  end

  def calculate_minimum_completion_time
    return 0 if @tasks.empty?

    # Forward pass: 最早開始時刻と最早終了時刻を計算
    calculate_earliest_times

    # プロジェクト全体の最短完了時間
    @tasks.values.map(&:earliest_finish).max
  end

  def calculate_critical_path
    return [] if @tasks.empty?

    # Forward pass
    calculate_earliest_times

    # Backward pass: 最遅開始時刻と最遅終了時刻を計算
    project_duration = @tasks.values.map(&:earliest_finish).max
    calculate_latest_times(project_duration)

    # スラックを計算
    @tasks.values.each do |task|
      task.slack = task.latest_start - task.earliest_start
    end

    # クリティカルパスを見つける
    find_critical_paths
  end

  def get_task_timeline
    return {} if @tasks.empty?

    calculate_earliest_times

    timeline = {}
    @tasks.each do |name, task|
      timeline[name] = {
        start: task.earliest_start,
        finish: task.earliest_finish,
        duration: task.duration
      }
    end

    timeline
  end

  def has_cycle?
    visited = Set.new
    rec_stack = Set.new

    @tasks.keys.each do |task|
      return true if !visited.include?(task) && detect_cycle_util(task, visited, rec_stack)
    end

    false
  end

  private

  def calculate_in_degrees
    in_degree = Hash.new(0)

    @tasks.keys.each do |task|
      in_degree[task] = @dependencies[task].size
    end

    in_degree
  end

  def calculate_earliest_times
    order = get_execution_order

    order.each do |task_name|
      task = @tasks[task_name]

      # 前提タスクの最早終了時刻の最大値を見つける
      max_prerequisite_finish = 0
      @dependencies[task_name].each do |prereq_name|
        prereq = @tasks[prereq_name]
        max_prerequisite_finish = [max_prerequisite_finish, prereq.earliest_finish].max
      end

      task.earliest_start = max_prerequisite_finish
      task.earliest_finish = task.earliest_start + task.duration
    end
  end

  def calculate_latest_times(project_duration)
    order = get_execution_order.reverse

    # 終端タスクの最遅終了時刻を設定
    @tasks.values.each do |task|
      if @reverse_dependencies[task.name].empty?
        task.latest_finish = project_duration
        task.latest_start = task.latest_finish - task.duration
      end
    end

    # 逆順で最遅時刻を計算
    order.each do |task_name|
      task = @tasks[task_name]

      # 後続タスクの最遅開始時刻の最小値を見つける
      min_successor_start = Float::INFINITY
      @reverse_dependencies[task_name].each do |succ_name|
        succ = @tasks[succ_name]
        min_successor_start = [min_successor_start, succ.latest_start].min
      end

      if min_successor_start < Float::INFINITY
        task.latest_finish = min_successor_start
        task.latest_start = task.latest_finish - task.duration
      end
    end
  end

  def find_critical_paths
    critical_tasks = @tasks.values.select(&:critical?)
    paths = []

    # 開始タスク（依存関係がない）を見つける
    start_tasks = critical_tasks.select { |task| @dependencies[task.name].empty? }

    start_tasks.each do |start_task|
      find_paths_from(start_task, [], paths, critical_tasks)
    end

    # 最長のパスを返す
    paths.max_by(&:length) || []
  end

  def find_paths_from(task, current_path, all_paths, critical_tasks)
    current_path += [task.name]

    successors = @reverse_dependencies[task.name].select do |succ_name|
      @tasks[succ_name].critical?
    end

    if successors.empty?
      all_paths << current_path
    else
      successors.each do |succ_name|
        find_paths_from(@tasks[succ_name], current_path, all_paths, critical_tasks)
      end
    end
  end

  def detect_cycle_util(task, visited, rec_stack)
    visited.add(task)
    rec_stack.add(task)

    @dependencies[task].each do |prereq|
      if !visited.include?(prereq)
        return true if detect_cycle_util(prereq, visited, rec_stack)
      elsif rec_stack.include?(prereq)
        return true
      end
    end

    rec_stack.delete(task)
    false
  end
end

# テスト
if __FILE__ == $0
  scheduler = TaskScheduler.new

  # プロジェクトのタスクを定義
  scheduler.add_task('設計', duration: 5)
  scheduler.add_task('実装', duration: 10)
  scheduler.add_task('テスト作成', duration: 3)
  scheduler.add_task('単体テスト', duration: 4)
  scheduler.add_task('統合テスト', duration: 6)
  scheduler.add_task('文書作成', duration: 3)
  scheduler.add_task('デプロイ', duration: 2)

  # 依存関係を定義
  scheduler.add_dependency('実装', '設計')
  scheduler.add_dependency('テスト作成', '設計')
  scheduler.add_dependency('単体テスト', '実装')
  scheduler.add_dependency('単体テスト', 'テスト作成')
  scheduler.add_dependency('統合テスト', '単体テスト')
  scheduler.add_dependency('文書作成', '実装')
  scheduler.add_dependency('デプロイ', '統合テスト')
  scheduler.add_dependency('デプロイ', '文書作成')

  puts '=== 実行順序 ==='
  order = scheduler.get_execution_order
  puts order.join(' → ')

  puts "\n=== 並列実行可能なグループ ==="
  groups = scheduler.get_parallel_groups
  groups.each_with_index do |group, i|
    puts "フェーズ #{i + 1}: #{group.join(', ')}"
  end

  puts "\n=== タスクタイムライン ==="
  timeline = scheduler.get_task_timeline
  timeline.each do |task, times|
    puts "#{task}: 開始=#{times[:start]}, 終了=#{times[:finish]}, 期間=#{times[:duration]}"
  end

  puts "\n=== プロジェクト情報 ==="
  min_time = scheduler.calculate_minimum_completion_time
  puts "最短完了時間: #{min_time}日"

  critical_path = scheduler.calculate_critical_path
  puts "クリティカルパス: #{critical_path.join(' → ')}"

  # 循環依存のテスト
  puts "\n=== 循環依存テスト ==="
  begin
    scheduler.add_dependency('設計', 'デプロイ')
  rescue StandardError => e
    puts "エラー: #{e.message}"
  end
end
