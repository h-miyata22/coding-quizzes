
# 簡易ファイルシステムを実装してください。
# このシステムは以下の機能を持つ必要があります：
#
# 1. ファイルとディレクトリを表現できる
# 2. ディレクトリは複数のファイルとサブディレクトリを含められる
# 3. 任意のパスでファイル/ディレクトリを検索できる
# 4. ディレクトリのサイズ（含まれる全ファイルの合計）を計算できる
# 5. 指定した拡張子のファイルを全て検索できる
# 6. ディレクトリツリーを視覚的に表示できる

# FileSystemNode（基底クラス）、File、Directory クラスを実装してください。

# 使用例:
# root = Directory.new("root")
# src = Directory.new("src")
# root.add(src)
# 
# src.add(File.new("main.rb", 1024))
# src.add(File.new("helper.rb", 512))
# 
# lib = Directory.new("lib")
# src.add(lib)
# lib.add(File.new("utils.rb", 256))
# 
# # パスで検索
# node = root.find_by_path("src/lib/utils.rb")
# # => File(name: "utils.rb", size: 256)
# 
# # ディレクトリサイズ
# src.total_size
# # => 1792
# 
# # 拡張子で検索
# rb_files = root.find_files_by_extension(".rb")
# # => [File("main.rb"), File("helper.rb"), File("utils.rb")]
# 
# # ツリー表示
# root.display_tree
# # root/
# # └── src/
# #     ├── main.rb (1024)
# #     ├── helper.rb (512)
# #     └── lib/
# #         └── utils.rb (256)
