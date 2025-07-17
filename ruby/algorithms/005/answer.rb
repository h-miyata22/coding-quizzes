class EditDistance
  def initialize
    @cache = {}
  end

  # レーベンシュタイン距離を計算（動的計画法）
  def calculate(str1, str2)
    cache_key = [str1, str2].sort.join('|')
    return @cache[cache_key] if @cache.key?(cache_key)

    m = str1.length
    n = str2.length

    # DPテーブルの初期化
    dp = Array.new(m + 1) { Array.new(n + 1, 0) }

    # 初期値の設定
    (0..m).each { |i| dp[i][0] = i }
    (0..n).each { |j| dp[0][j] = j }

    # DPテーブルの構築
    (1..m).each do |i|
      (1..n).each do |j|
        dp[i][j] = if str1[i - 1] == str2[j - 1]
                     dp[i - 1][j - 1]
                   else
                     [
                       dp[i - 1][j] + 1,    # 削除
                       dp[i][j - 1] + 1,    # 挿入
                       dp[i - 1][j - 1] + 1 # 置換
                     ].min
                   end
      end
    end

    @cache[cache_key] = dp[m][n]
    dp[m][n]
  end

  # 編集操作の詳細を取得
  def get_operations(str1, str2)
    m = str1.length
    n = str2.length

    # DPテーブルの構築
    dp = Array.new(m + 1) { Array.new(n + 1, 0) }

    (0..m).each { |i| dp[i][0] = i }
    (0..n).each { |j| dp[0][j] = j }

    (1..m).each do |i|
      (1..n).each do |j|
        dp[i][j] = if str1[i - 1] == str2[j - 1]
                     dp[i - 1][j - 1]
                   else
                     [
                       dp[i - 1][j] + 1,
                       dp[i][j - 1] + 1,
                       dp[i - 1][j - 1] + 1
                     ].min
                   end
      end
    end

    # バックトラックして操作を復元
    operations = []
    i = m
    j = n

    while i > 0 || j > 0
      if i > 0 && j > 0 && str1[i - 1] == str2[j - 1]
        i -= 1
        j -= 1
      elsif i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1
        operations << "replace '#{str1[i - 1]}' with '#{str2[j - 1]}' at position #{i - 1}"
        i -= 1
        j -= 1
      elsif i > 0 && dp[i][j] == dp[i - 1][j] + 1
        operations << "delete '#{str1[i - 1]}' at position #{i - 1}"
        i -= 1
      else
        operations << "insert '#{str2[j - 1]}' at position #{i}"
        j -= 1
      end
    end

    operations.reverse
  end

  def clear_cache
    @cache.clear
  end
end

class AutoCompleteSystem
  def initialize(dictionary)
    @dictionary = dictionary.sort
    @edit_distance = EditDistance.new
    @suggestion_cache = {}
  end

  def suggest(input, limit: 5)
    cache_key = "#{input}:#{limit}"
    return @suggestion_cache[cache_key] if @suggestion_cache.key?(cache_key)

    # 各単語との編集距離を計算
    distances = @dictionary.map do |word|
      {
        word: word,
        distance: @edit_distance.calculate(input, word)
      }
    end

    # 距離順にソートして上位N個を返す
    result = distances.sort_by { |item| [item[:distance], item[:word]] }
                      .first(limit)
                      .map { |item| item[:word] }

    @suggestion_cache[cache_key] = result
    result
  end

  def suggest_with_prefix(input, limit: 5)
    # 前方一致する単語を優先
    prefix_matches = []
    other_matches = []

    @dictionary.each do |word|
      distance = @edit_distance.calculate(input, word)
      item = { word: word, distance: distance }

      if word.start_with?(input)
        prefix_matches << item
      else
        other_matches << item
      end
    end

    # 前方一致を優先してソート
    sorted_prefix = prefix_matches.sort_by { |item| [item[:distance], item[:word]] }
    sorted_other = other_matches.sort_by { |item| [item[:distance], item[:word]] }

    (sorted_prefix + sorted_other).first(limit).map { |item| item[:word] }
  end

  def get_distance_details(str1, str2)
    distance = @edit_distance.calculate(str1, str2)
    operations = @edit_distance.get_operations(str1, str2)

    {
      distance: distance,
      operations: operations
    }
  end

  def add_word(word)
    @dictionary << word unless @dictionary.include?(word)
    @dictionary.sort!
    @suggestion_cache.clear
  end

  def clear_cache
    @suggestion_cache.clear
    @edit_distance.clear_cache
  end
end

# テスト
if __FILE__ == $0
  dictionary = %w[
    apple application apply appliance
    banana band bandana bandwidth
    code coder coding codec
    debug debugger debugging
    error errors errorlog
  ]

  system = AutoCompleteSystem.new(dictionary)

  puts '=== 編集距離による提案 ==='
  test_words = %w[aple banan cod debg eror]

  test_words.each do |word|
    suggestions = system.suggest(word, limit: 3)
    puts "Input: '#{word}' -> Suggestions: #{suggestions.join(', ')}"
  end

  puts "\n=== 前方一致を優先した提案 ==="
  prefixes = %w[app ban cod deb err]

  prefixes.each do |prefix|
    suggestions = system.suggest_with_prefix(prefix, limit: 3)
    puts "Prefix: '#{prefix}' -> Suggestions: #{suggestions.join(', ')}"
  end

  puts "\n=== 編集距離の詳細 ==="
  details = system.get_distance_details('aple', 'apple')
  puts "From 'aple' to 'apple':"
  puts "  Distance: #{details[:distance]}"
  puts '  Operations:'
  details[:operations].each { |op| puts "    - #{op}" }

  details = system.get_distance_details('debg', 'debug')
  puts "\nFrom 'debg' to 'debug':"
  puts "  Distance: #{details[:distance]}"
  puts '  Operations:'
  details[:operations].each { |op| puts "    - #{op}" }
end
