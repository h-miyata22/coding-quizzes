class DPTable
  def initialize(rows, cols = nil)
    if cols
      @table = Array.new(rows) { Array.new(cols, 0) }
      @rows = rows
      @cols = cols
    else
      @table = Array.new(rows, 0)
      @rows = rows
      @cols = 1
    end
  end

  def get(i, j = nil)
    if j
      @table[i][j]
    else
      @table[i]
    end
  end

  def set(i, j = nil, value = nil)
    if j && value
      @table[i][j] = value
    else
      @table[i] = j # jが実際の値
    end
  end

  def max_in_row(i)
    @table[i].max
  end

  def max_value
    if @cols == 1
      @table.max
    else
      @table.map(&:max).max
    end
  end
end

class SubsequenceSolver
  def longest_increasing_subsequence(arr)
    return { length: 0, sequence: [] } if arr.empty?

    n = arr.length
    dp = DPTable.new(n)
    parent = Array.new(n, -1)

    # dp[i] = i番目で終わるLISの長さ
    (0...n).each do |i|
      dp.set(i, 1)

      (0...i).each do |j|
        if arr[j] < arr[i] && dp.get(j) + 1 > dp.get(i)
          dp.set(i, dp.get(j) + 1)
          parent[i] = j
        end
      end
    end

    # 最長の部分列を復元
    max_length = dp.max_value
    max_index = (0...n).find { |i| dp.get(i) == max_length }

    sequence = reconstruct_path(arr, parent, max_index)

    { length: max_length, sequence: sequence }
  end

  def longest_increasing_subsequence_optimized(arr)
    return { length: 0, sequence: [] } if arr.empty?

    n = arr.length
    tails = [] # tails[i] = 長さi+1のLISの最小末尾値
    elements = [] # 実際の要素を保持
    parent = Array.new(n, -1)
    lis_indices = []

    arr.each_with_index do |num, i|
      # 二分探索でnumが入る位置を見つける
      pos = binary_search_position(tails, num)

      if pos == tails.length
        tails << num
        elements << i
      else
        tails[pos] = num
        elements[pos] = i
      end

      # 親を記録
      parent[i] = pos > 0 ? elements[pos - 1] : -1

      lis_indices = elements.dup if pos == tails.length - 1
    end

    # 最長の部分列を復元
    sequence = []
    idx = lis_indices.last
    while idx != -1
      sequence.unshift(arr[idx])
      idx = parent[idx]
    end

    { length: tails.length, sequence: sequence }
  end

  def max_subarray_sum(arr)
    return { sum: 0, start: -1, end: -1, subarray: [] } if arr.empty?

    max_sum = arr[0]
    current_sum = arr[0]
    start = 0
    temp_start = 0
    ending = 0

    (1...arr.length).each do |i|
      # 現在の要素を加えるか、新しく始めるか
      if current_sum < 0
        current_sum = arr[i]
        temp_start = i
      else
        current_sum += arr[i]
      end

      # 最大値を更新
      next unless current_sum > max_sum

      max_sum = current_sum
      start = temp_start
      ending = i
    end

    {
      sum: max_sum,
      start: start,
      end: ending,
      subarray: arr[start..ending]
    }
  end

  def longest_common_subsequence(str1, str2)
    m = str1.length
    n = str2.length

    dp = DPTable.new(m + 1, n + 1)

    # DPテーブルを構築
    (1..m).each do |i|
      (1..n).each do |j|
        if str1[i - 1] == str2[j - 1]
          dp.set(i, j, dp.get(i - 1, j - 1) + 1)
        else
          dp.set(i, j, [dp.get(i - 1, j), dp.get(i, j - 1)].max)
        end
      end
    end

    # LCSを復元
    lcs = reconstruct_lcs(str1, str2, dp, m, n)

    {
      length: dp.get(m, n),
      sequence: lcs
    }
  end

  def count_distinct_subsequences(str, target)
    m = str.length
    n = target.length

    return 0 if n > m

    dp = DPTable.new(m + 1, n + 1)

    # 空文字列は任意の文字列の部分列
    (0..m).each { |i| dp.set(i, 0, 1) }

    (1..m).each do |i|
      (1..n).each do |j|
        # 現在の文字を使わない場合
        count = dp.get(i - 1, j)

        # 現在の文字を使う場合
        count += dp.get(i - 1, j - 1) if str[i - 1] == target[j - 1]

        dp.set(i, j, count)
      end
    end

    dp.get(m, n)
  end

  def longest_palindromic_subsequence(str)
    n = str.length
    dp = DPTable.new(n, n)

    # 1文字は回文
    (0...n).each { |i| dp.set(i, i, 1) }

    # 部分文字列の長さを増やしながら計算
    (2..n).each do |length|
      (0..n - length).each do |i|
        j = i + length - 1

        if str[i] == str[j]
          dp.set(i, j, dp.get(i + 1, j - 1) + 2)
        else
          dp.set(i, j, [dp.get(i + 1, j), dp.get(i, j - 1)].max)
        end
      end
    end

    # 回文を復元
    palindrome = reconstruct_palindrome(str, dp, 0, n - 1)

    {
      length: dp.get(0, n - 1),
      sequence: palindrome
    }
  end

  def min_insertions_to_sort(arr)
    # ソートするために必要な最小挿入数 = n - LIS長
    lis_result = longest_increasing_subsequence_optimized(arr)

    {
      insertions: arr.length - lis_result[:length],
      lis: lis_result[:sequence]
    }
  end

  private

  def binary_search_position(tails, target)
    left = 0
    right = tails.length

    while left < right
      mid = (left + right) / 2
      if tails[mid] < target
        left = mid + 1
      else
        right = mid
      end
    end

    left
  end

  def reconstruct_path(arr, parent, end_index)
    path = []
    current = end_index

    while current != -1
      path.unshift(arr[current])
      current = parent[current]
    end

    path
  end

  def reconstruct_lcs(str1, str2, dp, i, j)
    return '' if i == 0 || j == 0

    if str1[i - 1] == str2[j - 1]
      reconstruct_lcs(str1, str2, dp, i - 1, j - 1) + str1[i - 1]
    elsif dp.get(i - 1, j) > dp.get(i, j - 1)
      reconstruct_lcs(str1, str2, dp, i - 1, j)
    else
      reconstruct_lcs(str1, str2, dp, i, j - 1)
    end
  end

  def reconstruct_palindrome(str, dp, i, j)
    return '' if i > j
    return str[i] if i == j

    if str[i] == str[j]
      str[i] + reconstruct_palindrome(str, dp, i + 1, j - 1) + str[j]
    elsif dp.get(i + 1, j) > dp.get(i, j - 1)
      reconstruct_palindrome(str, dp, i + 1, j)
    else
      reconstruct_palindrome(str, dp, i, j - 1)
    end
  end
end

# テスト
if __FILE__ == $0
  solver = SubsequenceSolver.new

  puts '=== Longest Increasing Subsequence ==='
  arr1 = [10, 9, 2, 5, 3, 7, 101, 18]
  lis = solver.longest_increasing_subsequence(arr1)
  puts "Array: #{arr1}"
  puts "LIS Length: #{lis[:length]}"
  puts "LIS: #{lis[:sequence]}"

  # 最適化版
  lis_opt = solver.longest_increasing_subsequence_optimized(arr1)
  puts "\nOptimized LIS: #{lis_opt[:sequence]}"

  puts "\n=== Maximum Subarray Sum ==="
  arr2 = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
  max_sub = solver.max_subarray_sum(arr2)
  puts "Array: #{arr2}"
  puts "Max Sum: #{max_sub[:sum]}"
  puts "Subarray: #{max_sub[:subarray]} (indices #{max_sub[:start]}-#{max_sub[:end]})"

  puts "\n=== Longest Common Subsequence ==="
  str1 = 'ABCDGH'
  str2 = 'AEDFHR'
  lcs = solver.longest_common_subsequence(str1, str2)
  puts "String 1: #{str1}"
  puts "String 2: #{str2}"
  puts "LCS Length: #{lcs[:length]}"
  puts "LCS: #{lcs[:sequence]}"

  puts "\n=== Count Distinct Subsequences ==="
  main_str = 'rabbbit'
  target = 'rabbit'
  count = solver.count_distinct_subsequences(main_str, target)
  puts "String: #{main_str}"
  puts "Target: #{target}"
  puts "Count: #{count}"

  puts "\n=== Longest Palindromic Subsequence ==="
  palindrome_str = 'bbbab'
  lps = solver.longest_palindromic_subsequence(palindrome_str)
  puts "String: #{palindrome_str}"
  puts "LPS Length: #{lps[:length]}"
  puts "LPS: #{lps[:sequence]}"

  puts "\n=== Minimum Insertions to Sort ==="
  arr3 = [5, 2, 8, 6, 3, 6, 9, 7]
  min_ins = solver.min_insertions_to_sort(arr3)
  puts "Array: #{arr3}"
  puts "Minimum insertions needed: #{min_ins[:insertions]}"
  puts "LIS in array: #{min_ins[:lis]}"
end
