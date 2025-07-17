require 'time'

class Player
  include Comparable

  attr_reader :name, :score, :last_played_at

  def initialize(name, score, last_played_at)
    @name = name
    @score = score
    @last_played_at = last_played_at
  end

  # 比較演算子のオーバーロード
  def <=>(other)
    # スコアの降順比較
    score_comparison = other.score <=> @score
    return score_comparison unless score_comparison == 0

    # スコアが同じ場合は、最終プレイ時刻の降順（新しい順）で比較
    other.last_played_at <=> @last_played_at
  end

  def to_s
    "Player(name: \"#{@name}\", score: #{@score})"
  end
end

class RankingSystem
  def initialize
    @players = []
  end

  def add_player(name, score, last_played_at)
    player = Player.new(name, score, last_played_at)
    @players << player
    heapify_up(@players.length - 1)
  end

  def get_top_players(n)
    result = []
    temp_heap = @players.dup

    n.times do
      break if temp_heap.empty?

      # ヒープのルート（最大要素）を取得
      result << temp_heap[0]

      # 最後の要素をルートに移動し、ヒープを再構築
      temp_heap[0] = temp_heap[-1]
      temp_heap.pop
      heapify_down_for_array(temp_heap, 0) unless temp_heap.empty?
    end

    result
  end

  def remove_lowest_scorer
    return nil if @players.empty?

    # 最低スコアのプレイヤーを見つける
    min_index = 0
    min_player = @players[0]

    @players.each_with_index do |player, index|
      next unless player.score < min_player.score ||
                  (player.score == min_player.score && player.last_played_at < min_player.last_played_at)

      min_player = player
      min_index = index
    end

    # 最後の要素と入れ替えて削除
    @players[min_index] = @players[-1]
    @players.pop

    # ヒープ性を回復
    heapify_up(min_index) if min_index < @players.length
    heapify_down(min_index) if min_index < @players.length

    min_player
  end

  def player_count
    @players.length
  end

  private

  def heapify_up(index)
    return if index == 0

    parent_index = (index - 1) / 2

    return unless @players[index] > @players[parent_index]

    @players[index], @players[parent_index] = @players[parent_index], @players[index]
    heapify_up(parent_index)
  end

  def heapify_down(index)
    left_child = 2 * index + 1
    right_child = 2 * index + 2
    largest = index

    largest = left_child if left_child < @players.length && @players[left_child] > @players[largest]

    largest = right_child if right_child < @players.length && @players[right_child] > @players[largest]

    return unless largest != index

    @players[index], @players[largest] = @players[largest], @players[index]
    heapify_down(largest)
  end

  def heapify_down_for_array(array, index)
    left_child = 2 * index + 1
    right_child = 2 * index + 2
    largest = index

    largest = left_child if left_child < array.length && array[left_child] > array[largest]

    largest = right_child if right_child < array.length && array[right_child] > array[largest]

    return unless largest != index

    array[index], array[largest] = array[largest], array[index]
    heapify_down_for_array(array, largest)
  end
end

# テスト
if __FILE__ == $0
  ranking = RankingSystem.new

  # プレイヤーを追加
  ranking.add_player('Alice', 1000, Time.now - 7200)
  ranking.add_player('Bob', 1200, Time.now - 3600)
  ranking.add_player('Charlie', 1200, Time.now)
  ranking.add_player('David', 800, Time.now - 1800)
  ranking.add_player('Eve', 1500, Time.now - 900)

  puts "Total players: #{ranking.player_count}"

  # トップ3を取得
  puts "\nTop 3 players:"
  ranking.get_top_players(3).each do |player|
    puts player
  end

  # 最低スコアのプレイヤーを削除
  removed = ranking.remove_lowest_scorer
  puts "\nRemoved player: #{removed}"

  puts "\nRemaining players: #{ranking.player_count}"

  # 再度トップ3を取得
  puts "\nTop 3 players after removal:"
  ranking.get_top_players(3).each do |player|
    puts player
  end
end
