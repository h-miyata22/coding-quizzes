require 'tempfile'

class UnixCommand
  attr_reader :type, :options

  def initialize(type, options = {})
    @type = type
    @options = options
  end

  def execute(input)
    case input
    when String
      # ファイル名が渡された場合
      if File.exist?(input)
        process_file(input)
      else
        # 文字列として処理
        process_lines(input.split("\n"))
      end
    when Array
      # 行の配列として処理
      process_lines(input)
    else
      raise ArgumentError, 'Invalid input type'
    end
  end

  def self.grep(pattern: nil, options: {})
    new(:grep, { pattern: pattern }.merge(options))
  end

  def self.sort(options = {})
    new(:sort, options)
  end

  def self.uniq(options = {})
    new(:uniq, options)
  end

  def self.wc(options = {})
    new(:wc, options)
  end

  def self.head(n = 10, options = {})
    new(:head, { lines: n }.merge(options))
  end

  def self.tail(n = 10, options = {})
    new(:tail, { lines: n }.merge(options))
  end

  private

  def process_file(filename)
    case @type
    when :grep
      grep_file(filename)
    when :sort
      sort_file(filename)
    when :wc
      wc_file(filename)
    else
      # その他のコマンドは全行読み込み
      lines = File.readlines(filename, chomp: true)
      process_lines(lines)
    end
  end

  def process_lines(lines)
    case @type
    when :grep
      grep_lines(lines)
    when :sort
      sort_lines(lines)
    when :uniq
      uniq_lines(lines)
    when :wc
      wc_lines(lines)
    when :head
      head_lines(lines)
    when :tail
      tail_lines(lines)
    else
      lines
    end
  end

  # grep実装
  def grep_file(filename)
    pattern = @options[:pattern]
    invert = @options[:invert] || false
    line_numbers = @options[:line_numbers] || false
    results = []

    File.foreach(filename).with_index do |line, index|
      line.chomp!
      matches = pattern.match?(line)
      matches = !matches if invert

      if matches
        results << if line_numbers
                     "#{index + 1}:#{line}"
                   else
                     line
                   end
      end
    end

    results
  end

  def grep_lines(lines)
    pattern = @options[:pattern]
    invert = @options[:invert] || false

    lines.select do |line|
      matches = pattern.match?(line)
      invert ? !matches : matches
    end
  end

  # sort実装
  def sort_file(filename)
    if @options[:external] && File.size(filename) > 100_000_000 # 100MB以上
      external_sort_file(filename)
    else
      lines = File.readlines(filename, chomp: true)
      sort_lines(lines)
    end
  end

  def sort_lines(lines)
    numeric = @options[:numeric] || false
    reverse = @options[:reverse] || false

    sorted = if numeric
               lines.sort_by { |line| line.to_f }
             else
               lines.sort
             end

    reverse ? sorted.reverse : sorted
  end

  def external_sort_file(filename)
    chunk_size = 10_000 # 一度に処理する行数
    temp_files = []

    # ファイルを分割してソート
    File.open(filename) do |file|
      until file.eof?
        chunk = []
        chunk_size.times do
          break if file.eof?

          chunk << file.readline.chomp
        end

        sorted_chunk = sort_lines(chunk)
        temp_file = Tempfile.new('sort_chunk')
        temp_file.puts(sorted_chunk)
        temp_file.close
        temp_files << temp_file
      end
    end

    # マージソート
    result = merge_sorted_files(temp_files)

    # 一時ファイルをクリーンアップ
    temp_files.each(&:unlink)

    result
  end

  def merge_sorted_files(temp_files)
    # K-wayマージ
    file_handles = temp_files.map { |tf| File.open(tf.path) }
    result = []
    heap = []

    # 各ファイルから最初の要素を読み込み
    file_handles.each_with_index do |fh, index|
      unless fh.eof?
        line = fh.readline.chomp
        heap << [line, index]
      end
    end

    # ヒープを構築
    heap.sort! { |a, b| compare_for_sort(a[0], b[0]) }

    until heap.empty?
      # 最小要素を取り出し
      line, file_index = heap.shift
      result << line

      # 同じファイルから次の要素を読み込み
      fh = file_handles[file_index]
      next if fh.eof?

      next_line = fh.readline.chomp
      # 適切な位置に挿入
      insert_position = heap.bsearch_index { |item| compare_for_sort(item[0], next_line) > 0 } || heap.size
      heap.insert(insert_position, [next_line, file_index])
    end

    file_handles.each(&:close)
    result
  end

  def compare_for_sort(a, b)
    if @options[:numeric]
      a.to_f <=> b.to_f
    else
      a <=> b
    end
  end

  # uniq実装
  def uniq_lines(lines)
    count = @options[:count] || false
    ignore_case = @options[:ignore_case] || false

    if count
      counts = Hash.new(0)
      lines.each do |line|
        key = ignore_case ? line.downcase : line
        counts[key] += 1
      end
      counts.map { |line, cnt| "#{cnt} #{line}" }
    else
      seen = Set.new
      lines.select do |line|
        key = ignore_case ? line.downcase : line
        seen.add?(key)
      end
    end
  end

  # wc実装
  def wc_file(filename)
    lines = 0
    words = 0
    chars = 0

    File.foreach(filename) do |line|
      lines += 1
      words += line.split.size
      chars += line.size
    end

    format_wc_output(lines, words, chars, filename)
  end

  def wc_lines(lines)
    line_count = lines.size
    word_count = lines.sum { |line| line.split.size }
    char_count = lines.sum { |line| line.size + 1 } # +1 for newline

    format_wc_output(line_count, word_count, char_count)
  end

  def format_wc_output(lines, words, chars, filename = nil)
    parts = []
    parts << lines if @options[:lines] != false
    parts << words if @options[:words]
    parts << chars if @options[:chars]

    # デフォルトは全て表示
    parts = [lines, words, chars] if parts.empty?

    result = parts.map(&:to_s).join(' ')
    result += " #{filename}" if filename
    result
  end

  # head/tail実装
  def head_lines(lines)
    n = @options[:lines] || 10
    lines.first(n)
  end

  def tail_lines(lines)
    n = @options[:lines] || 10
    lines.last(n)
  end
end

class Pipeline
  def initialize
    @commands = []
  end

  def grep(pattern, options = {})
    @commands << UnixCommand.grep(pattern: pattern, **options)
    self
  end

  def sort(options = {})
    @commands << UnixCommand.sort(options)
    self
  end

  def uniq(options = {})
    @commands << UnixCommand.uniq(options)
    self
  end

  def wc(options = {})
    @commands << UnixCommand.wc(options)
    self
  end

  def head(n = 10, options = {})
    @commands << UnixCommand.head(n, options)
    self
  end

  def tail(n = 10, options = {})
    @commands << UnixCommand.tail(n, options)
    self
  end

  def execute(input)
    result = input

    @commands.each do |command|
      result = command.execute(result)
    end

    result
  end

  def stream_execute(filename)
    # ストリーミング実行（メモリ効率的）
    StreamProcessor.new(filename).pipe(self)
  end
end

class StreamProcessor
  def initialize(filename)
    @filename = filename
    @buffer_size = 1024 * 1024 # 1MB
  end

  def each_matching(pattern)
    line_number = 0

    File.foreach(@filename) do |line|
      line_number += 1
      yield(line.chomp, line_number) if pattern.match?(line.chomp)
    end
  end

  def pipe(pipeline)
    # パイプラインをストリーミングで実行
    # 簡易実装：最初のgrepのみストリーミング対応
    first_command = pipeline.instance_variable_get(:@commands).first

    if first_command && first_command.type == :grep
      pattern = first_command.options[:pattern]
      results = []

      each_matching(pattern) do |line, _|
        results << line

        # バッファサイズに達したら中間処理
        next unless results.size >= 1000

        # 残りのコマンドを実行
        remaining_commands = pipeline.instance_variable_get(:@commands)[1..-1]
        temp_pipeline = Pipeline.new
        remaining_commands.each { |cmd| temp_pipeline.instance_variable_get(:@commands) << cmd }

        yield temp_pipeline.execute(results) if block_given?
        results.clear
      end

      # 残りのデータを処理
      unless results.empty?
        remaining_commands = pipeline.instance_variable_get(:@commands)[1..-1]
        temp_pipeline = Pipeline.new
        remaining_commands.each { |cmd| temp_pipeline.instance_variable_get(:@commands) << cmd }

        yield temp_pipeline.execute(results) if block_given?
      end
    else
      # ストリーミング非対応の場合は通常実行
      result = pipeline.execute(@filename)
      yield result if block_given?
    end
  end

  def count_lines
    count = 0
    File.foreach(@filename) { count += 1 }
    count
  end

  def sample(n = 10, seed = nil)
    # リザーバーサンプリング
    rng = seed ? Random.new(seed) : Random.new
    reservoir = []
    line_number = 0

    File.foreach(@filename) do |line|
      line_number += 1

      if reservoir.size < n
        reservoir << line.chomp
      else
        j = rng.rand(line_number)
        reservoir[j] = line.chomp if j < n
      end
    end

    reservoir
  end
end

# テスト
if __FILE__ == $0
  # テスト用のデータを作成
  test_data = <<~DATA
    apple 10
    banana 5
    apple 10
    cherry 15
    date 20
    banana 5
    elderberry 25
  DATA

  File.write('test_data.txt', test_data)

  puts '=== Individual Commands ==='

  # grep
  grep_cmd = UnixCommand.grep(pattern: /apple|banana/)
  puts 'Grep results:'
  puts grep_cmd.execute('test_data.txt')

  # sort
  puts "\nSort (numeric):"
  sort_cmd = UnixCommand.sort(numeric: true)
  puts sort_cmd.execute(%w[30 5 100 20])

  # uniq with count
  puts "\nUniq with count:"
  uniq_cmd = UnixCommand.uniq(count: true)
  puts uniq_cmd.execute(test_data.split("\n"))

  # wc
  puts "\nWord count:"
  wc_cmd = UnixCommand.wc
  puts wc_cmd.execute('test_data.txt')

  puts "\n=== Pipeline Example ==="
  pipeline = Pipeline.new
                     .grep(/\d+/)
                     .sort
                     .uniq
                     .head(5)

  result = pipeline.execute('test_data.txt')
  puts 'Pipeline result:'
  puts result

  puts "\n=== Streaming Example ==="
  # 大きなファイルのシミュレーション
  File.open('large_test.txt', 'w') do |f|
    10_000.times do |i|
      f.puts "line #{i}: #{%w[apple banana cherry].sample} #{rand(100)}"
    end
  end

  stream = StreamProcessor.new('large_test.txt')

  puts 'Sampling 5 random lines:'
  puts stream.sample(5)

  puts "\nMatching lines (first 5):"
  count = 0
  stream.each_matching(/apple.*[5-9]\d/) do |line, line_number|
    puts "#{line_number}: #{line}"
    count += 1
    break if count >= 5
  end

  # クリーンアップ
  File.delete('test_data.txt') if File.exist?('test_data.txt')
  File.delete('large_test.txt') if File.exist?('large_test.txt')
end
