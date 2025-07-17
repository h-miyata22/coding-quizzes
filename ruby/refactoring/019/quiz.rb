class DataProcessor
  def process_data(input_file, output_file, options = {})
    # データ読み込み
    data = []
    File.open(input_file, 'r') do |f|
      f.each_line do |line|
        data << line.strip
      end
    end

    # バリデーション
    valid_data = []
    invalid_count = 0
    for i in 0..data.length - 1
      line = data[i]

      # 空行チェック
      if line.empty?
        invalid_count += 1
        next
      end

      # 長さチェック
      if options[:max_length] && line.length > options[:max_length]
        invalid_count += 1
        next
      end

      # パターンチェック
      if options[:pattern] && !line.match(options[:pattern])
        invalid_count += 1
        next
      end

      valid_data << line
    end

    # 変換処理
    transformed_data = []
    for i in 0..valid_data.length - 1
      line = valid_data[i]

      # 大文字変換
      line = line.upcase if options[:uppercase]

      # 小文字変換
      line = line.downcase if options[:lowercase]

      # プレフィックス追加
      line = options[:prefix] + line if options[:prefix]

      # サフィックス追加
      line += options[:suffix] if options[:suffix]

      # 置換処理
      line = line.gsub(options[:replace_from], options[:replace_to]) if options[:replace_from] && options[:replace_to]

      transformed_data << line
    end

    # フィルタリング
    filtered_data = []
    for i in 0..transformed_data.length - 1
      line = transformed_data[i]

      # 重複削除
      next if options[:unique] && filtered_data.include?(line)

      # キーワードフィルタ
      next if options[:include_keyword] && !line.include?(options[:include_keyword])

      next if options[:exclude_keyword] && line.include?(options[:exclude_keyword])

      filtered_data << line
    end

    # ソート
    if options[:sort]
      # バブルソート
      for i in 0..filtered_data.length - 1
        for j in i + 1..filtered_data.length - 1
          next unless filtered_data[i] > filtered_data[j]

          temp = filtered_data[i]
          filtered_data[i] = filtered_data[j]
          filtered_data[j] = temp
        end
      end
    end

    # 結果出力
    File.open(output_file, 'w') do |f|
      for i in 0..filtered_data.length - 1
        f.puts filtered_data[i]
      end
    end

    # 統計情報
    puts 'Processing completed:'
    puts "  Total lines: #{data.length}"
    puts "  Invalid lines: #{invalid_count}"
    puts "  Output lines: #{filtered_data.length}"

    {
      total: data.length,
      invalid: invalid_count,
      output: filtered_data.length
    }
  end
end
