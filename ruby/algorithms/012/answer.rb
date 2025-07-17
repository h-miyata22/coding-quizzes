class HuffmanNode
  attr_accessor :char, :frequency, :left, :right

  def initialize(char = nil, frequency = 0)
    @char = char
    @frequency = frequency
    @left = nil
    @right = nil
  end

  def leaf?
    @left.nil? && @right.nil?
  end

  def <=>(other)
    @frequency <=> other.frequency
  end
end

class HuffmanCoding
  def initialize
    @encoding_table = {}
    @root = nil
  end

  def compress(text)
    return { data: '', tree: nil } if text.empty?

    # 文字の頻度を計算
    frequencies = calculate_frequencies(text)

    # ハフマン木を構築
    @root = build_huffman_tree(frequencies)

    # 符号化テーブルを生成
    @encoding_table = {}
    generate_codes(@root, '')

    # テキストを圧縮
    compressed_data = encode_text(text)

    {
      data: compressed_data,
      tree: @root,
      encoding_table: @encoding_table.dup
    }
  end

  def decompress(compressed_data, tree)
    return '' if compressed_data.empty? || tree.nil?

    result = []
    current_node = tree

    compressed_data.each_char do |bit|
      current_node = if bit == '0'
                       current_node.left
                     else
                       current_node.right
                     end

      if current_node.leaf?
        result << current_node.char
        current_node = tree
      end
    end

    result.join
  end

  def get_encoding_table(text)
    frequencies = calculate_frequencies(text)
    tree = build_huffman_tree(frequencies)

    encoding_table = {}
    generate_codes(tree, '', encoding_table)

    encoding_table
  end

  def compression_stats(text)
    return { original_bits: 0, compressed_bits: 0, compression_ratio: 0 } if text.empty?

    compressed = compress(text)

    original_bits = text.length * 8 # 各文字8ビットと仮定
    compressed_bits = compressed[:data].length
    compression_ratio = 1.0 - (compressed_bits.to_f / original_bits)

    {
      original_bits: original_bits,
      compressed_bits: compressed_bits,
      compression_ratio: compression_ratio.round(3),
      unique_chars: compressed[:encoding_table].size,
      avg_code_length: calculate_average_code_length(text, compressed[:encoding_table])
    }
  end

  def visualize_tree(node = @root, prefix = '', is_tail = true)
    return '' if node.nil?

    result = []

    connector = is_tail ? '└── ' : '├── '
    result << if node.leaf?
                "#{prefix}#{connector}'#{node.char}' (#{node.frequency})"
              else
                "#{prefix}#{connector}Internal (#{node.frequency})"
              end

    if node.left || node.right
      extension = is_tail ? '    ' : '│   '

      result << visualize_tree(node.left, prefix + extension, false) if node.left

      result << visualize_tree(node.right, prefix + extension, true) if node.right
    end

    result.join("\n")
  end

  private

  def calculate_frequencies(text)
    frequencies = Hash.new(0)
    text.each_char { |char| frequencies[char] += 1 }
    frequencies
  end

  def build_huffman_tree(frequencies)
    # 優先度付きキューの代わりに配列を使用
    heap = frequencies.map { |char, freq| HuffmanNode.new(char, freq) }
    heap.sort!

    while heap.size > 1
      # 最小の2つのノードを取り出す
      left = heap.shift
      right = heap.shift

      # 新しい内部ノードを作成
      parent = HuffmanNode.new
      parent.frequency = left.frequency + right.frequency
      parent.left = left
      parent.right = right

      # ヒープに戻す（適切な位置に挿入）
      insert_position = heap.bsearch_index { |node| node.frequency >= parent.frequency } || heap.size
      heap.insert(insert_position, parent)
    end

    heap.first
  end

  def generate_codes(node, code, table = @encoding_table)
    return if node.nil?

    if node.leaf?
      # 単一文字の場合の特別処理
      table[node.char] = code.empty? ? '0' : code
    else
      generate_codes(node.left, code + '0', table)
      generate_codes(node.right, code + '1', table)
    end
  end

  def encode_text(text)
    text.chars.map { |char| @encoding_table[char] }.join
  end

  def calculate_average_code_length(text, encoding_table)
    total_length = 0
    char_count = text.length

    text.each_char do |char|
      total_length += encoding_table[char].length
    end

    (total_length.to_f / char_count).round(2)
  end
end

# ハフマン木のシリアライズ/デシリアライズ（実用的な圧縮用）
class HuffmanTreeSerializer
  def self.serialize(root)
    return '' if root.nil?

    if root.leaf?
      "1#{root.char}"
    else
      "0#{serialize(root.left)}#{serialize(root.right)}"
    end
  end

  def self.deserialize(data)
    return nil if data.empty?

    index = [0]
    deserialize_helper(data, index)
  end

  def self.deserialize_helper(data, index)
    return nil if index[0] >= data.length

    if data[index[0]] == '1'
      index[0] += 1
      char = data[index[0]]
      index[0] += 1
      HuffmanNode.new(char, 0)
    else
      index[0] += 1
      node = HuffmanNode.new
      node.left = deserialize_helper(data, index)
      node.right = deserialize_helper(data, index)
      node
    end
  end
end

# テスト
if __FILE__ == $0
  huffman = HuffmanCoding.new

  puts '=== Basic Compression ==='
  text = 'hello world'
  compressed = huffman.compress(text)

  puts "Original text: \"#{text}\""
  puts "Compressed data: #{compressed[:data]}"
  puts "\nEncoding table:"
  compressed[:encoding_table].sort.each do |char, code|
    puts "  '#{char}' => #{code}"
  end

  decompressed = huffman.decompress(compressed[:data], compressed[:tree])
  puts "\nDecompressed: \"#{decompressed}\""
  puts "Match: #{text == decompressed}"

  puts "\n=== Compression Statistics ==="
  stats = huffman.compression_stats(text)
  puts "Original size: #{stats[:original_bits]} bits"
  puts "Compressed size: #{stats[:compressed_bits]} bits"
  puts "Compression ratio: #{(stats[:compression_ratio] * 100).round(1)}%"
  puts "Average code length: #{stats[:avg_code_length]} bits"

  puts "\n=== Huffman Tree Visualization ==="
  puts huffman.visualize_tree(compressed[:tree])

  puts "\n=== Different Text Compression ==="
  texts = [
    'aaaaaabbbbcccdde',
    'the quick brown fox jumps over the lazy dog',
    'aaaaaaaaaa'
  ]

  texts.each do |test_text|
    stats = huffman.compression_stats(test_text)
    puts "\nText: \"#{test_text[0..30]}#{test_text.length > 30 ? '...' : ''}\""
    puts "Compression ratio: #{(stats[:compression_ratio] * 100).round(1)}%"
    puts "Unique chars: #{stats[:unique_chars]}"
  end

  puts "\n=== Tree Serialization Test ==="
  serialized = HuffmanTreeSerializer.serialize(compressed[:tree])
  puts "Serialized tree: #{serialized}"

  deserialized_tree = HuffmanTreeSerializer.deserialize(serialized)
  test_decompressed = huffman.decompress(compressed[:data], deserialized_tree)
  puts "Decompression after deserialization: #{test_decompressed == text}"
end
