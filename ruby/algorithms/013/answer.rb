class BTreeNode
  attr_accessor :keys, :values, :children, :leaf, :parent

  def initialize(order, leaf = true)
    @order = order
    @keys = []
    @values = []
    @children = []
    @leaf = leaf
    @parent = nil
  end

  def full?
    @keys.size >= 2 * @order - 1
  end

  def min_keys
    @leaf ? @order - 1 : @order
  end
end

class BTree
  attr_reader :root, :order

  def initialize(order: 3)
    raise 'Order must be at least 2' if order < 2

    @order = order
    @root = BTreeNode.new(@order)
    @size = 0
  end

  def insert(key, value)
    if @root.full?
      # ルートが満杯の場合、新しいルートを作成
      new_root = BTreeNode.new(@order, false)
      new_root.children << @root
      @root.parent = new_root
      split_child(new_root, 0)
      @root = new_root
    end

    insert_non_full(@root, key, value)
    @size += 1
  end

  def search(key)
    node, index = search_node(@root, key)
    node && index >= 0 ? node.values[index] : nil
  end

  def delete(key)
    deleted = delete_key(@root, key)

    # ルートが空になった場合の処理
    if @root.keys.empty? && !@root.leaf
      @root = @root.children[0] if @root.children.size > 0
      @root.parent = nil if @root
    end

    @size -= 1 if deleted
    deleted
  end

  def range_search(min_key, max_key)
    results = []
    range_search_helper(@root, min_key, max_key, results)
    results
  end

  def statistics
    height = calculate_height(@root)
    node_count = count_nodes(@root)
    total_capacity = node_count * (2 * @order - 1)
    fill_rate = @size.to_f / total_capacity

    {
      height: height,
      nodes: node_count,
      keys: @size,
      fill_rate: fill_rate.round(2),
      avg_keys_per_node: (@size.to_f / node_count).round(2)
    }
  end

  def visualize(node = @root, prefix = '', is_tail = true)
    return '' if node.nil?

    result = []
    connector = is_tail ? '└── ' : '├── '

    # ノードのキーを表示
    keys_str = node.keys.join(', ')
    result << "#{prefix}#{connector}[#{keys_str}]"

    # 子ノードを表示
    unless node.leaf
      extension = is_tail ? '    ' : '│   '
      node.children.each_with_index do |child, i|
        is_last = i == node.children.size - 1
        result << visualize(child, prefix + extension, is_last)
      end
    end

    result.join("\n")
  end

  private

  def insert_non_full(node, key, value)
    i = node.keys.size - 1

    if node.leaf
      # リーフノードに挿入
      node.keys << nil
      node.values << nil

      while i >= 0 && node.keys[i] && key < node.keys[i]
        node.keys[i + 1] = node.keys[i]
        node.values[i + 1] = node.values[i]
        i -= 1
      end

      node.keys[i + 1] = key
      node.values[i + 1] = value
    else
      # 内部ノードの場合、適切な子を見つける
      i -= 1 while i >= 0 && node.keys[i] && node.keys[i] && key < node.keys[i]
      i += 1

      if node.children[i].full?
        split_child(node, i)
        i += 1 if node.keys[i] && key > node.keys[i]
      end

      insert_non_full(node.children[i], key, value)
    end
  end

  def split_child(parent, index)
    order = @order
    full_child = parent.children[index]
    new_child = BTreeNode.new(order, full_child.leaf)

    # 中央のキーのインデックス
    mid = order - 1

    # 後半のキーと値を新しいノードに移動
    new_child.keys = full_child.keys[mid + 1..-1]
    new_child.values = full_child.values[mid + 1..-1]
    full_child.keys = full_child.keys[0...mid]
    full_child.values = full_child.values[0...mid]

    # 子ノードも分割（内部ノードの場合）
    unless full_child.leaf
      new_child.children = full_child.children[mid + 1..-1]
      full_child.children = full_child.children[0..mid]

      # 親の更新
      new_child.children.each { |child| child.parent = new_child }
    end

    # 中央のキーを親に挿入
    parent.keys.insert(index, full_child.keys[mid])
    parent.values.insert(index, full_child.values[mid])
    parent.children.insert(index + 1, new_child)

    # 親の設定
    new_child.parent = parent
  end

  def search_node(node, key)
    return [nil, -1] if node.nil?

    i = 0
    i += 1 while i < node.keys.size && node.keys[i] && key > node.keys[i]

    if i < node.keys.size && key == node.keys[i]
      [node, i]
    elsif node.leaf
      [nil, -1]
    else
      search_node(node.children[i], key)
    end
  end

  def range_search_helper(node, min_key, max_key, results)
    return if node.nil?

    i = 0

    # 各キーと子ノードを処理
    while i < node.keys.size
      # 左の子ノードを探索
      range_search_helper(node.children[i], min_key, max_key, results) if !node.leaf && i < node.children.size

      # 現在のキーが範囲内かチェック
      if node.keys[i] && node.keys[i] >= min_key && node.keys[i] <= max_key
        results << [node.keys[i], node.values[i]]
      elsif node.keys[i] && node.keys[i] > max_key
        return
      end

      i += 1
    end

    # 最後の子ノードを探索
    return unless !node.leaf && i < node.children.size

    range_search_helper(node.children[i], min_key, max_key, results)
  end

  def delete_key(node, key)
    i = 0
    i += 1 while i < node.keys.size && node.keys[i] && key > node.keys[i]

    if i < node.keys.size && key == node.keys[i]
      return delete_internal_node(node, key, i) unless node.leaf

      # リーフノードから削除
      node.keys.delete_at(i)
      node.values.delete_at(i)
      true

    # 内部ノードから削除

    elsif node.leaf
      false # キーが見つからない
    else
      # 子ノードで削除を試みる
      is_in_subtree = (i == node.keys.size)

      if node.children[i].keys.size < @order
        fill_child(node, i)

        # fillの後でインデックスを再計算
        i = 0
        i += 1 while i < node.keys.size && node.keys[i] && key > node.keys[i]
      end

      return delete_key(node.children[i - 1], key) if is_in_subtree && i > node.keys.size

      delete_key(node.children[i], key)

    end
  end

  def delete_internal_node(node, key, index)
    node.keys[index]

    if node.children[index].keys.size >= @order
      # 左の子から先行キーを取得
      predecessor = get_predecessor(node, index)
      node.keys[index] = predecessor[:key]
      node.values[index] = predecessor[:value]
      delete_key(node.children[index], predecessor[:key])
    elsif node.children[index + 1].keys.size >= @order
      # 右の子から後続キーを取得
      successor = get_successor(node, index)
      node.keys[index] = successor[:key]
      node.values[index] = successor[:value]
      delete_key(node.children[index + 1], successor[:key])
    else
      # 両方の子が最小キー数の場合、マージ
      merge(node, index)
      delete_key(node.children[index], key)
    end
  end

  def get_predecessor(node, index)
    current = node.children[index]
    current = current.children[-1] until current.leaf
    { key: current.keys[-1], value: current.values[-1] }
  end

  def get_successor(node, index)
    current = node.children[index + 1]
    current = current.children[0] until current.leaf
    { key: current.keys[0], value: current.values[0] }
  end

  def fill_child(node, index)
    # 子ノードが最小キー数未満の場合、兄弟から借りるかマージ
    if index != 0 && node.children[index - 1].keys.size >= @order
      borrow_from_prev(node, index)
    elsif index != node.children.size - 1 && node.children[index + 1].keys.size >= @order
      borrow_from_next(node, index)
    elsif index != node.children.size - 1
      merge(node, index)
    else
      merge(node, index - 1)
    end
  end

  def borrow_from_prev(node, child_index)
    child = node.children[child_index]
    sibling = node.children[child_index - 1]

    # 親のキーを子に移動
    child.keys.unshift(node.keys[child_index - 1])
    child.values.unshift(node.values[child_index - 1])

    # 兄弟の最後のキーを親に移動
    node.keys[child_index - 1] = sibling.keys.pop
    node.values[child_index - 1] = sibling.values.pop

    # 子ノードも移動（内部ノードの場合）
    return if child.leaf

    child.children.unshift(sibling.children.pop)
    child.children[0].parent = child
  end

  def borrow_from_next(node, child_index)
    child = node.children[child_index]
    sibling = node.children[child_index + 1]

    # 親のキーを子に移動
    child.keys.push(node.keys[child_index])
    child.values.push(node.values[child_index])

    # 兄弟の最初のキーを親に移動
    node.keys[child_index] = sibling.keys.shift
    node.values[child_index] = sibling.values.shift

    # 子ノードも移動（内部ノードの場合）
    return if child.leaf

    child.children.push(sibling.children.shift)
    child.children[-1].parent = child
  end

  def merge(node, index)
    child = node.children[index]
    sibling = node.children[index + 1]

    # 親のキーと兄弟のキーを子にマージ
    child.keys.push(node.keys[index])
    child.values.push(node.values[index])
    child.keys.concat(sibling.keys)
    child.values.concat(sibling.values)

    # 子ノードもマージ（内部ノードの場合）
    unless child.leaf
      child.children.concat(sibling.children)
      sibling.children.each { |c| c.parent = child }
    end

    # 親から削除
    node.keys.delete_at(index)
    node.values.delete_at(index)
    node.children.delete_at(index + 1)
  end

  def calculate_height(node)
    return 0 if node.nil?
    return 1 if node.leaf

    1 + calculate_height(node.children[0])
  end

  def count_nodes(node)
    return 0 if node.nil?

    count = 1
    node.children.each { |child| count += count_nodes(child) }
    count
  end
end

# テスト
if __FILE__ == $0
  btree = BTree.new(order: 3)

  puts '=== B-Tree Insertion ==='
  values = [10, 20, 5, 6, 12, 30, 7, 17, 25, 27, 15, 1, 3, 8]

  values.each do |val|
    btree.insert(val, "Data#{val}")
    puts "Inserted #{val}"
  end

  puts "\n=== B-Tree Structure ==="
  puts btree.visualize

  puts "\n=== Search Operations ==="
  [15, 25, 100].each do |key|
    result = btree.search(key)
    puts "Search #{key}: #{result || 'Not found'}"
  end

  puts "\n=== Range Search ==="
  results = btree.range_search(10, 20)
  puts 'Range [10, 20]:'
  results.each { |k, v| puts "  #{k} => #{v}" }

  puts "\n=== Statistics ==="
  stats = btree.statistics
  stats.each { |k, v| puts "#{k}: #{v}" }

  puts "\n=== Deletion ==="
  [6, 12, 20].each do |key|
    btree.delete(key)
    puts "Deleted #{key}"
  end

  puts "\n=== B-Tree After Deletion ==="
  puts btree.visualize

  puts "\n=== Final Statistics ==="
  stats = btree.statistics
  stats.each { |k, v| puts "#{k}: #{v}" }
end
