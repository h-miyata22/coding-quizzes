# 基底クラス
class FileSystemNode
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def file?
    false
  end

  def directory?
    false
  end

  def total_size
    raise NotImplementedError
  end

  def find_by_path(path)
    raise NotImplementedError
  end

  def find_files_by_extension(extension)
    raise NotImplementedError
  end
end

# ファイルクラス
class FileNode < FileSystemNode
  attr_reader :size

  def initialize(name, size)
    super(name)
    @size = size
  end

  def file?
    true
  end

  def total_size
    @size
  end

  def find_by_path(path)
    path == @name ? self : nil
  end

  def find_files_by_extension(extension)
    @name.end_with?(extension) ? [self] : []
  end

  def to_s
    "FileNode(name: \"#{@name}\", size: #{@size})"
  end
end

# ディレクトリクラス
class Directory < FileSystemNode
  def initialize(name)
    super(name)
    @children = []
  end

  def directory?
    true
  end

  def add(node)
    @children << node
  end

  def remove(node)
    @children.delete(node)
  end

  def total_size
    @children.sum { |child| child.total_size }
  end

  def find_by_path(path)
    parts = path.split('/')

    # 最初の部分が自分の名前と一致しない場合
    return nil unless parts[0] == @name

    # パスが自分の名前だけの場合
    return self if parts.length == 1

    # 残りのパスで子要素を探索
    remaining_path = parts[1..-1].join('/')

    @children.each do |child|
      result = child.find_by_path(remaining_path)
      return result if result
    end

    nil
  end

  def find_files_by_extension(extension)
    files = []

    @children.each do |child|
      files.concat(child.find_files_by_extension(extension))
    end

    files
  end

  def display_tree(prefix = '', is_last = true)
    puts "#{prefix}#{is_last ? '└── ' : '├── '}#{@name}/"

    @children.each_with_index do |child, index|
      is_child_last = index == @children.length - 1
      child_prefix = prefix + (is_last ? '    ' : '│   ')

      if child.directory?
        child.display_tree(child_prefix, is_child_last)
      else
        connector = is_child_last ? '└── ' : '├── '
        puts "#{child_prefix}#{connector}#{child.name} (#{child.size})"
      end
    end
  end

  def to_s
    "Directory(name: \"#{@name}\")"
  end
end

# テスト
if __FILE__ == $0
  # ファイルシステムの構築
  root = Directory.new('root')

  # srcディレクトリ
  src = Directory.new('src')
  root.add(src)

  src.add(FileNode.new('main.rb', 1024))
  src.add(FileNode.new('helper.rb', 512))
  src.add(FileNode.new('config.yml', 128))

  # libディレクトリ
  lib = Directory.new('lib')
  src.add(lib)
  lib.add(FileNode.new('utils.rb', 256))
  lib.add(FileNode.new('validator.rb', 384))

  # testsディレクトリ
  tests = Directory.new('tests')
  root.add(tests)
  tests.add(FileNode.new('test_main.rb', 512))
  tests.add(FileNode.new('test_utils.rb', 256))

  puts '=== File System Tree ==='
  puts 'root/'
  root.display_tree('', true)

  puts "\n=== Path Search ==="
  node = root.find_by_path('root/src/lib/utils.rb')
  puts "Search 'root/src/lib/utils.rb': #{node}"

  node = root.find_by_path('root/src/config.yml')
  puts "Search 'root/src/config.yml': #{node}"

  puts "\n=== Directory Sizes ==="
  puts "Total size of root: #{root.total_size} bytes"
  puts "Total size of src: #{src.total_size} bytes"
  puts "Total size of lib: #{lib.total_size} bytes"

  puts "\n=== Find by Extension ==="
  rb_files = root.find_files_by_extension('.rb')
  puts "Ruby files found: #{rb_files.length}"
  rb_files.each { |file| puts "  - #{file.name} (#{file.size} bytes)" }

  yml_files = root.find_files_by_extension('.yml')
  puts "\nYAML files found: #{yml_files.length}"
  yml_files.each { |file| puts "  - #{file.name} (#{file.size} bytes)" }
end
