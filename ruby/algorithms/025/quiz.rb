
# Unixコマンドラインツールの実装を行ってください。
# パイプライン処理とストリーム処理を効率的に実現し、
# 大規模ファイルも扱えるようにします。
#
# 要件：
# 1. grep（パターン検索）の実装
# 2. sort（ソート）の実装（外部ソート対応）
# 3. uniq（重複除去）の実装
# 4. wc（単語数カウント）の実装
# 5. パイプライン処理の実装
# 6. ストリーミング処理による省メモリ化

# UnixCommand, Pipeline, StreamProcessor クラスを実装してください。

# 使用例:
# # 単一コマンドの実行
# grep = UnixCommand.grep(pattern: /error/i)
# result = grep.execute("log.txt")
# # => ["ERROR: Connection failed", "Error in line 42"]
# 
# # パイプライン処理
# pipeline = Pipeline.new
#   .grep(/^\d+/)           # 数字で始まる行
#   .sort(numeric: true)    # 数値としてソート
#   .uniq                   # 重複除去
#   .head(10)              # 上位10件
# 
# pipeline.execute("data.txt")
# 
# # ストリーミング処理（大規模ファイル対応）
# stream = StreamProcessor.new("huge_file.txt")
# stream.each_matching(/pattern/) do |line, line_number|
#   puts "#{line_number}: #{line}"
# end
