class GameState
  attr_reader :board, :board_size, :current_player

  def initialize(board_size: 3, board: nil)
    @board_size = board_size
    @board = board || Array.new(board_size) { Array.new(board_size, nil) }
    @current_player = :X
  end

  def make_move(row, col, player = @current_player)
    return false unless valid_move?(row, col)

    new_board = @board.map(&:dup)
    new_board[row][col] = player

    new_state = GameState.new(board_size: @board_size, board: new_board)
    new_state.instance_variable_set(:@current_player, opponent(player))
    new_state
  end

  def valid_move?(row, col)
    row.between?(0, @board_size - 1) &&
      col.between?(0, @board_size - 1) &&
      @board[row][col].nil?
  end

  def available_moves
    moves = []
    @board_size.times do |row|
      @board_size.times do |col|
        moves << [row, col] if @board[row][col].nil?
      end
    end
    moves
  end

  def game_over?
    winner || draw?
  end

  def winner
    # 行をチェック
    @board.each do |row|
      if row.all? { |cell| cell == :X }
        return :X
      elsif row.all? { |cell| cell == :O }
        return :O
      end
    end

    # 列をチェック
    @board_size.times do |col|
      column = @board.map { |row| row[col] }
      if column.all? { |cell| cell == :X }
        return :X
      elsif column.all? { |cell| cell == :O }
        return :O
      end
    end

    # 対角線をチェック
    diagonal1 = (0...@board_size).map { |i| @board[i][i] }
    diagonal2 = (0...@board_size).map { |i| @board[i][@board_size - 1 - i] }

    [diagonal1, diagonal2].each do |diagonal|
      if diagonal.all? { |cell| cell == :X }
        return :X
      elsif diagonal.all? { |cell| cell == :O }
        return :O
      end
    end

    nil
  end

  def draw?
    available_moves.empty? && winner.nil?
  end

  def opponent(player)
    player == :X ? :O : :X
  end

  def to_s
    @board.map do |row|
      row.map { |cell| cell ? cell.to_s : '-' }.join(' | ')
    end.join("\n")
  end
end

class MoveEvaluator
  def initialize
    @position_values = {}
    @pattern_scores = {}
    initialize_position_values
  end

  def evaluate_position(game_state, player)
    return terminal_score(game_state, player) if game_state.game_over?

    score = 0

    # 位置による評価
    score += position_score(game_state, player)

    # パターンによる評価
    score += pattern_score(game_state, player)

    # 中心制御の評価
    score += center_control_score(game_state, player)

    # 潜在的な勝利ラインの評価
    score += potential_win_score(game_state, player)

    score
  end

  private

  def terminal_score(game_state, player)
    winner = game_state.winner
    if winner == player
      1000
    elsif winner == game_state.opponent(player)
      -1000
    else
      0 # 引き分け
    end
  end

  def initialize_position_values
    # 3x3ボードの位置価値（中心ほど高い）
    @position_values[3] = [
      [3, 2, 3],
      [2, 4, 2],
      [3, 2, 3]
    ]
  end

  def position_score(game_state, player)
    score = 0
    size = game_state.board_size
    values = @position_values[size] || generate_position_values(size)

    size.times do |row|
      size.times do |col|
        if game_state.board[row][col] == player
          score += values[row][col]
        elsif game_state.board[row][col] == game_state.opponent(player)
          score -= values[row][col]
        end
      end
    end

    score * 10
  end

  def generate_position_values(size)
    values = Array.new(size) { Array.new(size, 0) }
    center = size / 2

    size.times do |row|
      size.times do |col|
        distance = [(row - center).abs, (col - center).abs].max
        values[row][col] = size - distance
      end
    end

    values
  end

  def pattern_score(game_state, player)
    score = 0
    lines = get_all_lines(game_state)

    lines.each do |line|
      player_count = line.count(player)
      opponent_count = line.count(game_state.opponent(player))
      line.count(nil)

      # 勝利可能なラインの評価
      if opponent_count == 0
        score += case player_count
                 when 2 then 50   # あと1手で勝利
                 when 1 then 10   # 潜在的な勝利ライン
                 else 0
                 end
      end

      # 相手の勝利を防ぐ必要がある
      if player_count == 0 && opponent_count == 2
        score -= 45 # 相手があと1手で勝利
      end
    end

    score
  end

  def center_control_score(game_state, player)
    return 0 if game_state.board_size.even?

    center = game_state.board_size / 2
    if game_state.board[center][center] == player
      20
    elsif game_state.board[center][center] == game_state.opponent(player)
      -20
    else
      0
    end
  end

  def potential_win_score(game_state, player)
    score = 0
    lines = get_all_lines(game_state)

    lines.each do |line|
      score += line.count(player) * 5 if line.count(game_state.opponent(player)) == 0
      score -= line.count(game_state.opponent(player)) * 5 if line.count(player) == 0
    end

    score
  end

  def get_all_lines(game_state)
    lines = []
    size = game_state.board_size

    # 行
    game_state.board.each { |row| lines << row }

    # 列
    size.times do |col|
      lines << game_state.board.map { |row| row[col] }
    end

    # 対角線
    lines << (0...size).map { |i| game_state.board[i][i] }
    lines << (0...size).map { |i| game_state.board[i][size - 1 - i] }

    lines
  end
end

class GameAI
  def initialize(max_depth: 9)
    @max_depth = max_depth
    @evaluator = MoveEvaluator.new
    @transposition_table = {}
    @move_history = []
  end

  def find_best_move(game_state, player:)
    return nil if game_state.game_over?

    best_score = -Float::INFINITY
    best_move = nil
    alpha = -Float::INFINITY
    beta = Float::INFINITY

    moves = order_moves(game_state.available_moves, game_state, player)

    moves.each do |move|
      new_state = game_state.make_move(move[0], move[1], player)
      score = minimax(new_state, @max_depth - 1, alpha, beta, false, player)

      if score > best_score
        best_score = score
        best_move = move
      end

      alpha = [alpha, score].max
    end

    @move_history << { move: best_move, score: best_score }
    { position: best_move, score: best_score }
  end

  def evaluate_all_moves(game_state, player:)
    return [] if game_state.game_over?

    moves = []

    game_state.available_moves.each do |move|
      new_state = game_state.make_move(move[0], move[1], player)
      score = minimax(new_state, @max_depth - 1, -Float::INFINITY, Float::INFINITY, false, player)
      moves << { position: move, score: score }
    end

    moves.sort_by { |m| -m[:score] }
  end

  def iterative_deepening_search(game_state, player:, time_limit: 5)
    start_time = Time.now
    best_move = nil

    (1..@max_depth).each do |depth|
      break if Time.now - start_time > time_limit

      @transposition_table.clear
      current_best = find_best_move_at_depth(game_state, player, depth)
      best_move = current_best if current_best

      # 必勝手を見つけたら早期終了
      break if best_move && best_move[:score] >= 900
    end

    best_move
  end

  private

  def minimax(state, depth, alpha, beta, maximizing_player, original_player)
    # トランスポジションテーブルをチェック
    state_key = state_to_key(state)
    if @transposition_table.key?(state_key) && @transposition_table[state_key][:depth] >= depth
      return @transposition_table[state_key][:score]
    end

    # 終端状態または深度制限
    if depth == 0 || state.game_over?
      score = @evaluator.evaluate_position(state, original_player)
      @transposition_table[state_key] = { score: score, depth: depth }
      return score
    end

    if maximizing_player
      max_eval = -Float::INFINITY

      order_moves(state.available_moves, state, original_player).each do |move|
        new_state = state.make_move(move[0], move[1], state.current_player)
        eval = minimax(new_state, depth - 1, alpha, beta, false, original_player)
        max_eval = [max_eval, eval].max
        alpha = [alpha, eval].max

        break if beta <= alpha  # アルファベータ枝刈り
      end

      @transposition_table[state_key] = { score: max_eval, depth: depth }
      max_eval
    else
      min_eval = Float::INFINITY

      order_moves(state.available_moves, state, state.current_player).each do |move|
        new_state = state.make_move(move[0], move[1], state.current_player)
        eval = minimax(new_state, depth - 1, alpha, beta, true, original_player)
        min_eval = [min_eval, eval].min
        beta = [beta, eval].min

        break if beta <= alpha  # アルファベータ枝刈り
      end

      @transposition_table[state_key] = { score: min_eval, depth: depth }
      min_eval
    end
  end

  def order_moves(moves, state, _player)
    # キラー手ヒューリスティック：以前良かった手を優先
    scored_moves = moves.map do |move|
      priority = 0

      # 中心に近い手を優先
      center = state.board_size / 2
      distance = [(move[0] - center).abs, (move[1] - center).abs].max
      priority -= distance * 10

      # 履歴ヒューリスティック
      @move_history.each_with_index do |history, i|
        priority += history[:score] / (i + 1) if history[:move] == move && history[:score] > 0
      end

      { move: move, priority: priority }
    end

    scored_moves.sort_by { |m| -m[:priority] }.map { |m| m[:move] }
  end

  def state_to_key(state)
    state.board.flatten.map { |cell| cell || '-' }.join
  end

  def find_best_move_at_depth(game_state, player, depth)
    temp_depth = @max_depth
    @max_depth = depth
    result = find_best_move(game_state, player: player)
    @max_depth = temp_depth
    result
  end
end

# テスト
if __FILE__ == $0
  puts '=== Tic-Tac-Toe AI Test ==='

  # ゲーム状態を作成
  game = GameState.new(board_size: 3)
  ai = GameAI.new(max_depth: 9)

  # 初期盤面
  puts 'Initial board:'
  puts game

  # いくつか手を打つ
  game = game.make_move(0, 0, :X)  # X plays top-left
  game = game.make_move(1, 1, :O)  # O plays center
  game = game.make_move(0, 1, :X)  # X plays top-middle

  puts "\nCurrent board:"
  puts game

  # AIが次の最適手を計算
  puts "\n=== AI Analysis ==="
  best_move = ai.find_best_move(game, player: :O)
  puts "Best move for O: #{best_move[:position]} with score: #{best_move[:score]}"

  # 全ての手を評価
  puts "\n=== All Move Evaluations ==="
  all_moves = ai.evaluate_all_moves(game, player: :O)
  all_moves.each do |move|
    puts "Position #{move[:position]}: Score = #{move[:score]}"
  end

  # ゲームを続ける
  if best_move[:position]
    game = game.make_move(best_move[:position][0], best_move[:position][1], :O)
    puts "\n=== After AI Move ==="
    puts game
  end

  # 評価関数のテスト
  puts "\n=== Position Evaluation ==="
  evaluator = MoveEvaluator.new
  score = evaluator.evaluate_position(game, :O)
  puts "Current position score for O: #{score}"
end
