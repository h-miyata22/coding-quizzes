class TrieNode
  attr_accessor :children, :is_word, :frequency, :word

  def initialize
    @children = {}
    @is_word = false
    @frequency = 0
    @word = nil
  end
end

class Dictionary
  def initialize
    @root = TrieNode.new
    @word_count = 0
    @total_nodes = 1
  end

  def add_word(word, frequency: 1)
    node = @root

    word.each_char do |char|
      unless node.children.key?(char)
        node.children[char] = TrieNode.new
        @total_nodes += 1
      end
      node = node.children[char]
    end

    # 既に単語が存在する場合は頻度を更新
    if node.is_word
      node.frequency += frequency
    else
      node.is_word = true
      node.frequency = frequency
      node.word = word
      @word_count += 1
    end
  end

  def search(word)
    node = find_node(word)
    node && node.is_word
  end

  def delete_word(word)
    delete_helper(@root, word, 0)
  end

  def find_with_prefix(prefix)
    node = find_node(prefix)
    return [] unless node

    words = []
    collect_words(node, words)
    words.sort
  end

  def wildcard_search(pattern)
    results = []
    wildcard_search_helper(@root, pattern, 0, '', results)
    results.sort
  end

  def get_top_words_by_frequency(limit)
    all_words = []
    collect_words_with_frequency(@root, all_words)

    all_words.sort_by { |word, freq| [-freq, word] }
             .first(limit)
  end

  def starts_with?(prefix)
    find_node(prefix) != nil
  end

  attr_reader :word_count

  def node_count
    @total_nodes
  end

  def suggest_corrections(word, max_distance: 2)
    suggestions = []

    # 編集距離を使った類似単語の検索
    collect_all_words(@root, '') do |dict_word|
      distance = edit_distance(word, dict_word)
      suggestions << [dict_word, distance] if distance <= max_distance && distance > 0
    end

    suggestions.sort_by { |word, dist| [dist, word] }
               .map { |word, _| word }
  end

  def memory_usage_estimate
    # ノードごとの概算メモリ使用量
    node_size = 40 # 基本的なオブジェクトサイズ
    hash_overhead = 40 # childrenハッシュのオーバーヘッド
    per_child_overhead = 16 # ハッシュエントリごとのオーバーヘッド

    total_memory = @total_nodes * (node_size + hash_overhead)

    # 各ノードの子要素によるメモリ使用量を推定
    total_memory_ref = [total_memory]
    estimate_children_memory(@root, total_memory_ref, per_child_overhead)

    total_memory_ref[0]
  end

  private

  def find_node(word)
    node = @root

    word.each_char do |char|
      return nil unless node.children.key?(char)

      node = node.children[char]
    end

    node
  end

  def collect_words(node, words)
    words << node.word if node.is_word

    node.children.each_value do |child|
      collect_words(child, words)
    end
  end

  def collect_words_with_frequency(node, words)
    words << [node.word, node.frequency] if node.is_word

    node.children.each_value do |child|
      collect_words_with_frequency(child, words)
    end
  end

  def collect_all_words(node, current_word, &block)
    yield current_word if node.is_word

    node.children.each do |char, child|
      collect_all_words(child, current_word + char, &block)
    end
  end

  def wildcard_search_helper(node, pattern, index, current_word, results)
    if index == pattern.length
      results << current_word if node.is_word
      return
    end

    char = pattern[index]

    if char == '.'
      # ワイルドカード: 全ての子ノードを探索
      node.children.each do |next_char, child|
        wildcard_search_helper(child, pattern, index + 1, current_word + next_char, results)
      end
    elsif node.children.key?(char)
      # 通常の文字: 対応する子ノードのみ探索
      wildcard_search_helper(node.children[char], pattern, index + 1, current_word + char, results)
    end
  end

  def delete_helper(node, word, index)
    return false if node.nil?

    if index == word.length
      # 単語の終端に到達
      if node.is_word
        node.is_word = false
        node.frequency = 0
        node.word = nil
        @word_count -= 1

        # 子ノードがない場合はtrueを返して削除可能を示す
        return node.children.empty?
      end
      return false
    end

    char = word[index]
    child = node.children[char]

    return false unless child

    should_delete_child = delete_helper(child, word, index + 1)

    if should_delete_child
      node.children.delete(char)
      @total_nodes -= 1

      # 現在のノードも削除可能か確認
      return !node.is_word && node.children.empty?
    end

    false
  end

  def edit_distance(str1, str2)
    m = str1.length
    n = str2.length

    dp = Array.new(m + 1) { Array.new(n + 1, 0) }

    (0..m).each { |i| dp[i][0] = i }
    (0..n).each { |j| dp[0][j] = j }

    (1..m).each do |i|
      (1..n).each do |j|
        dp[i][j] = if str1[i - 1] == str2[j - 1]
                     dp[i - 1][j - 1]
                   else
                     [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].min + 1
                   end
      end
    end

    dp[m][n]
  end

  def estimate_children_memory(node, total_memory, per_child_overhead)
    total_memory[0] += node.children.size * per_child_overhead

    node.children.each_value do |child|
      estimate_children_memory(child, total_memory, per_child_overhead)
    end
  end
end

# テスト
if __FILE__ == $0
  dict = Dictionary.new

  # 単語を追加
  words_with_freq = [
    ['cat', 10], ['car', 15], ['card', 5], ['care', 8],
    ['cut', 12], ['cup', 7], ['dog', 20], ['dot', 3],
    ['door', 6], ['done', 9], ['data', 11], ['date', 4]
  ]

  words_with_freq.each do |word, freq|
    dict.add_word(word, frequency: freq)
  end

  puts '=== Basic Search ==='
  %w[car cat can dog].each do |word|
    puts "search('#{word}'): #{dict.search(word)}"
  end

  puts "\n=== Prefix Search ==="
  %w[ca do da].each do |prefix|
    words = dict.find_with_prefix(prefix)
    puts "prefix '#{prefix}': #{words.join(', ')}"
  end

  puts "\n=== Wildcard Search ==="
  ['c.t', 'd..', 'c.r.'].each do |pattern|
    matches = dict.wildcard_search(pattern)
    puts "pattern '#{pattern}': #{matches.join(', ')}"
  end

  puts "\n=== Top Words by Frequency ==="
  top_words = dict.get_top_words_by_frequency(5)
  top_words.each do |word, freq|
    puts "#{word}: #{freq}"
  end

  puts "\n=== Spell Suggestions ==="
  %w[carr dof dta].each do |word|
    suggestions = dict.suggest_corrections(word, max_distance: 1)
    puts "#{word} → #{suggestions.join(', ')}"
  end

  puts "\n=== Dictionary Stats ==="
  puts "Total words: #{dict.word_count}"
  puts "Total nodes: #{dict.node_count}"
  puts "Estimated memory: #{dict.memory_usage_estimate} bytes"

  puts "\n=== Delete Word ==="
  dict.delete_word('car')
  puts "After deleting 'car':"
  puts "search('car'): #{dict.search('car')}"
  puts "Words with prefix 'ca': #{dict.find_with_prefix('ca').join(', ')}"
end
