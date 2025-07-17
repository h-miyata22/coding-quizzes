class PatternAnalyzer
  def compute_lps_array(pattern)
    # Longest Proper Prefix which is also Suffix
    m = pattern.length
    lps = Array.new(m, 0)
    length = 0
    i = 1

    while i < m
      if pattern[i] == pattern[length]
        length += 1
        lps[i] = length
        i += 1
      elsif length != 0
        length = lps[length - 1]
      else
        lps[i] = 0
        i += 1
      end
    end

    lps
  end

  def compute_bad_char_table(pattern)
    table = Hash.new(-1)

    pattern.each_char.with_index do |char, index|
      table[char] = index
    end

    table
  end

  def compute_good_suffix_table(pattern)
    m = pattern.length
    suffix = Array.new(m, 0)
    good_suffix = Array.new(m, 0)

    # 最後の文字から始めて接尾辞を計算
    suffix[m - 1] = m
    g = m - 1

    (m - 2).downto(0) do |i|
      if i > g && suffix[i + m - 1 - f] < i - g
        suffix[i] = suffix[i + m - 1 - f]
      else
        g = i if i < g
        f = i
        g -= 1 while g >= 0 && pattern[g] == pattern[g + m - 1 - f]
        suffix[i] = f - g
      end
    end

    # Good suffix tableを構築
    (0...m).each { |i| good_suffix[i] = m }

    j = 0
    (m - 1).downto(0) do |i|
      next unless suffix[i] == i + 1

      while j < m - 1 - i
        good_suffix[j] = m - 1 - i if good_suffix[j] == m
        j += 1
      end
    end

    (0...m - 1).each do |i|
      good_suffix[m - 1 - suffix[i]] = m - 1 - i
    end

    good_suffix
  end

  def rolling_hash(str, length, prime = 101, base = 256)
    hash = 0
    power = 1

    (0...length).each do |i|
      hash = (hash * base + str[i].ord) % prime
      power = (power * base) % prime if i < length - 1
    end

    [hash, power]
  end
end

class StringMatcher
  def initialize
    @analyzer = PatternAnalyzer.new
    @comparison_count = 0
  end

  def kmp_search(text, pattern)
    reset_comparison_count
    n = text.length
    m = pattern.length
    positions = []

    return { positions: positions, count: 0, comparisons: 0 } if m > n

    # LPS配列を計算
    lps = @analyzer.compute_lps_array(pattern)

    i = 0  # textのインデックス
    j = 0  # patternのインデックス

    while i < n
      @comparison_count += 1

      if text[i] == pattern[j]
        i += 1
        j += 1
      end

      if j == m
        positions << i - j
        j = lps[j - 1]
      elsif i < n && text[i] != pattern[j]
        if j != 0
          j = lps[j - 1]
        else
          i += 1
        end
      end
    end

    {
      positions: positions,
      count: positions.length,
      comparisons: @comparison_count
    }
  end

  def boyer_moore_search(text, pattern)
    reset_comparison_count
    n = text.length
    m = pattern.length
    positions = []

    return { positions: positions, count: 0, comparisons: 0 } if m > n

    # Bad character tableを構築
    bad_char = @analyzer.compute_bad_char_table(pattern)

    s = 0 # シフト量

    while s <= n - m
      j = m - 1

      # パターンを右から左に比較
      while j >= 0
        @comparison_count += 1
        break if text[s + j] != pattern[j]

        j -= 1
      end

      if j < 0
        # マッチ発見
        positions << s

        # 次の位置へシフト
        s += s + m < n ? m - bad_char[text[s + m]] : 1
      else
        # ミスマッチ
        shift = j - bad_char[text[s + j]]
        s += [shift, 1].max
      end
    end

    {
      positions: positions,
      count: positions.length,
      comparisons: @comparison_count
    }
  end

  def rabin_karp_search(text, pattern, prime = 101)
    reset_comparison_count
    n = text.length
    m = pattern.length
    positions = []
    base = 256

    return { positions: positions, count: 0, comparisons: 0 } if m > n

    # パターンのハッシュ値を計算
    pattern_hash, h = @analyzer.rolling_hash(pattern, m, prime, base)

    # 最初のウィンドウのハッシュ値を計算
    text_hash, = @analyzer.rolling_hash(text, m, prime, base)

    # テキストをスライディングウィンドウで走査
    (0..n - m).each do |i|
      @comparison_count += 1

      # ハッシュ値が一致したら文字列を比較
      if (pattern_hash == text_hash) && (text[i...i + m] == pattern)
        @comparison_count += m
        positions << i
      end

      # 次のウィンドウのハッシュ値を計算（ローリングハッシュ）
      if i < n - m
        text_hash = (base * (text_hash - text[i].ord * h) + text[i + m].ord) % prime
        text_hash += prime if text_hash < 0
      end
    end

    {
      positions: positions,
      count: positions.length,
      comparisons: @comparison_count
    }
  end

  def multi_pattern_search(text, patterns)
    # 簡易的な実装（各パターンを個別に検索）
    results = {}

    patterns.each do |pattern|
      result = kmp_search(text, pattern)
      results[pattern] = result[:positions]
    end

    results
  end

  def approximate_search(text, pattern, max_distance: 1)
    results = []
    n = text.length
    m = pattern.length

    (0..n - m).each do |i|
      substring = text[i...i + m]
      distance = edit_distance(substring, pattern)

      results << { position: i, distance: distance, match: substring } if distance <= max_distance
    end

    # より短い/長い部分文字列も考慮
    [-max_distance, 0, max_distance].each do |delta|
      next if m + delta <= 0 || m + delta > n

      (0..n - (m + delta)).each do |i|
        substring = text[i...i + m + delta]
        distance = edit_distance(substring, pattern)

        if distance <= max_distance && distance == delta.abs
          results << { position: i, distance: distance, match: substring }
        end
      end
    end

    results.uniq { |r| r[:position] }
  end

  def compare_algorithms(text, pattern)
    algorithms = {
      kmp: -> { kmp_search(text, pattern) },
      boyer_moore: -> { boyer_moore_search(text, pattern) },
      rabin_karp: -> { rabin_karp_search(text, pattern) }
    }

    results = {}

    algorithms.each do |name, algorithm|
      start_time = Time.now
      result = algorithm.call
      end_time = Time.now

      results[name] = {
        positions: result[:positions],
        comparisons: result[:comparisons],
        time: (end_time - start_time) * 1000 # ミリ秒
      }
    end

    results
  end

  private

  def reset_comparison_count
    @comparison_count = 0
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
                     1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].min
                   end
      end
    end

    dp[m][n]
  end
end

# 文字列照合の可視化
class StringMatchVisualizer
  def self.visualize_search(text, pattern, positions)
    puts "Text: #{text}"
    puts "Pattern: #{pattern}"
    puts "Matches at positions: #{positions}"

    # マッチ位置を視覚化
    visual = ' ' * text.length
    positions.each do |pos|
      pattern.length.times do |i|
        visual[pos + i] = '^' if pos + i < text.length
      end
    end

    puts "      #{visual}"
  end

  def self.show_lps_array(pattern)
    analyzer = PatternAnalyzer.new
    lps = analyzer.compute_lps_array(pattern)

    puts "\nLPS Array for pattern '#{pattern}':"
    puts "Index:   #{(0...pattern.length).to_a.join(' ')}"
    puts "Pattern: #{pattern.chars.join(' ')}"
    puts "LPS:     #{lps.join(' ')}"
  end
end

# テスト
if __FILE__ == $0
  matcher = StringMatcher.new

  puts '=== String Matching Algorithms ==='
  text = 'ababcababa'
  pattern = 'ababa'

  puts "Text: '#{text}'"
  puts "Pattern: '#{pattern}'"

  puts "\n=== KMP Algorithm ==="
  kmp_result = matcher.kmp_search(text, pattern)
  puts "Positions: #{kmp_result[:positions]}"
  puts "Comparisons: #{kmp_result[:comparisons]}"
  StringMatchVisualizer.visualize_search(text, pattern, kmp_result[:positions])
  StringMatchVisualizer.show_lps_array(pattern)

  puts "\n=== Boyer-Moore Algorithm ==="
  bm_result = matcher.boyer_moore_search(text, pattern)
  puts "Positions: #{bm_result[:positions]}"
  puts "Comparisons: #{bm_result[:comparisons]}"

  puts "\n=== Rabin-Karp Algorithm ==="
  rk_result = matcher.rabin_karp_search(text, pattern)
  puts "Positions: #{rk_result[:positions]}"
  puts "Comparisons: #{rk_result[:comparisons]}"

  puts "\n=== Multi-Pattern Search ==="
  patterns = %w[ab ba abc aba]
  multi_results = matcher.multi_pattern_search(text, patterns)
  multi_results.each do |pat, positions|
    puts "Pattern '#{pat}': #{positions}"
  end

  puts "\n=== Approximate Search ==="
  approx_pattern = 'abaca'
  approx_results = matcher.approximate_search(text, approx_pattern, max_distance: 1)
  puts "Approximate matches for '#{approx_pattern}' (max distance: 1):"
  approx_results.each do |result|
    puts "  Position #{result[:position]}: '#{result[:match]}' (distance: #{result[:distance]})"
  end

  puts "\n=== Algorithm Comparison ==="
  long_text = 'a' * 1000 + 'b'
  long_pattern = 'a' * 10 + 'b'

  comparison = matcher.compare_algorithms(long_text, long_pattern)
  puts "Text length: #{long_text.length}, Pattern length: #{long_pattern.length}"
  comparison.each do |algo, result|
    puts "#{algo}:"
    puts "  Matches: #{result[:positions].length}"
    puts "  Comparisons: #{result[:comparisons]}"
    puts "  Time: #{'%.3f' % result[:time]}ms"
  end
end
