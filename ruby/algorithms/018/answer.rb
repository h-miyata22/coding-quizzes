require 'set'

class DecisionNode
  attr_accessor :attribute, :value, :children, :label, :samples

  def initialize
    @attribute = nil  # 分割に使う属性
    @value = nil      # 属性の値（葉ノードの場合はクラスラベル）
    @children = {}    # 子ノード
    @label = nil      # 葉ノードのクラスラベル
    @samples = 0      # このノードに到達するサンプル数
  end

  def leaf?
    @children.empty?
  end

  def add_child(attribute_value, node)
    @children[attribute_value] = node
  end
end

class DataSet
  attr_reader :data, :attributes, :target

  def initialize(data, target)
    @data = data
    @target = target
    @attributes = data.first.keys - [target]
  end

  def size
    @data.size
  end

  def target_values
    @data.map { |row| row[@target] }
  end

  def attribute_values(attribute)
    @data.map { |row| row[attribute] }.uniq
  end

  def split_by_attribute(attribute)
    splits = Hash.new { |h, k| h[k] = [] }

    @data.each do |row|
      value = row[attribute]
      splits[value] << row
    end

    splits.transform_values { |subset| DataSet.new(subset, @target) }
  end

  def filter_by_value(attribute, value)
    filtered_data = @data.select { |row| row[attribute] == value }
    DataSet.new(filtered_data, @target)
  end
end

class DecisionTree
  def initialize(max_depth: nil, min_samples_split: 2)
    @root = nil
    @max_depth = max_depth
    @min_samples_split = min_samples_split
    @attributes = []
    @target = nil
  end

  def train(data, target:)
    @target = target
    dataset = DataSet.new(data, target)
    @attributes = dataset.attributes
    @root = build_tree(dataset, @attributes.dup, 0)
  end

  def predict(sample)
    return nil unless @root

    node = @root

    until node.leaf?
      attribute = node.attribute
      value = sample[attribute]

      # 未知の値の場合、最も多いパスを選択
      node = if node.children.key?(value)
               node.children[value]
             else
               # 最も多くのサンプルを持つ子ノードを選択
               node.children.values.max_by(&:samples)
             end
    end

    node.label
  end

  def extract_rules
    return [] unless @root

    rules = []
    extract_rules_helper(@root, [], rules)
    rules
  end

  def visualize(node = @root, indent = '')
    return '' unless node

    result = []

    if node.leaf?
      result << "#{indent}└── [#{node.label}] (#{node.samples} samples)"
    else
      result << "#{indent}├── #{node.attribute} ?"

      node.children.each_with_index do |(value, child), index|
        is_last = index == node.children.size - 1
        connector = is_last ? '└──' : '├──'
        extension = is_last ? '    ' : '│   '

        result << "#{indent}#{connector} #{value}"
        result << visualize(child, indent + extension)
      end
    end

    result.join("\n")
  end

  def accuracy(test_data)
    correct = 0

    test_data.each do |sample|
      target_value = sample[@target]
      sample_without_target = sample.reject { |k, _| k == @target }
      prediction = predict(sample_without_target)

      correct += 1 if prediction == target_value
    end

    correct.to_f / test_data.size
  end

  private

  def build_tree(dataset, remaining_attributes, depth)
    node = DecisionNode.new
    node.samples = dataset.size

    # 終了条件
    target_values = dataset.target_values

    # 全て同じクラスの場合
    if target_values.uniq.size == 1
      node.label = target_values.first
      return node
    end

    # 属性がない、深さ制限、最小サンプル数に達した場合
    if remaining_attributes.empty? ||
       (@max_depth && depth >= @max_depth) ||
       dataset.size < @min_samples_split
      node.label = majority_class(target_values)
      return node
    end

    # 最適な属性を選択
    best_attribute = select_best_attribute(dataset, remaining_attributes)
    return node unless best_attribute

    node.attribute = best_attribute

    # 属性で分割
    splits = dataset.split_by_attribute(best_attribute)
    new_remaining = remaining_attributes - [best_attribute]

    splits.each do |value, subset|
      child = build_tree(subset, new_remaining, depth + 1)
      node.add_child(value, child)
    end

    node
  end

  def entropy(values)
    return 0 if values.empty?

    counts = Hash.new(0)
    values.each { |v| counts[v] += 1 }

    total = values.size.to_f

    counts.values.sum do |count|
      probability = count / total
      probability > 0 ? -probability * Math.log2(probability) : 0
    end
  end

  def information_gain(dataset, attribute)
    # 分割前のエントロピー
    initial_entropy = entropy(dataset.target_values)

    # 分割後の重み付きエントロピー
    splits = dataset.split_by_attribute(attribute)
    weighted_entropy = 0

    splits.each do |_, subset|
      weight = subset.size.to_f / dataset.size
      weighted_entropy += weight * entropy(subset.target_values)
    end

    # 情報利得
    initial_entropy - weighted_entropy
  end

  def select_best_attribute(dataset, attributes)
    return nil if attributes.empty?

    gains = {}

    attributes.each do |attribute|
      gains[attribute] = information_gain(dataset, attribute)
    end

    # 最大の情報利得を持つ属性を選択
    best_attribute = gains.max_by { |_, gain| gain }
    best_attribute ? best_attribute[0] : nil
  end

  def majority_class(values)
    counts = Hash.new(0)
    values.each { |v| counts[v] += 1 }
    counts.max_by { |_, count| count }[0]
  end

  def extract_rules_helper(node, conditions, rules)
    if node.leaf?
      if conditions.any?
        rule = 'IF ' + conditions.join(' AND ') + " THEN #{@target} = #{node.label}"
        rules << rule
      else
        rules << "#{@target} = #{node.label}"
      end
    else
      node.children.each do |value, child|
        new_conditions = conditions + ["#{node.attribute} = #{value}"]
        extract_rules_helper(child, new_conditions, rules)
      end
    end
  end
end

# テスト
if __FILE__ == $0
  # 天気データセット
  training_data = [
    { outlook: 'sunny', temperature: 'hot', humidity: 'high', wind: 'weak', play: 'no' },
    { outlook: 'sunny', temperature: 'hot', humidity: 'high', wind: 'strong', play: 'no' },
    { outlook: 'overcast', temperature: 'hot', humidity: 'high', wind: 'weak', play: 'yes' },
    { outlook: 'rain', temperature: 'mild', humidity: 'high', wind: 'weak', play: 'yes' },
    { outlook: 'rain', temperature: 'cool', humidity: 'normal', wind: 'weak', play: 'yes' },
    { outlook: 'rain', temperature: 'cool', humidity: 'normal', wind: 'strong', play: 'no' },
    { outlook: 'overcast', temperature: 'cool', humidity: 'normal', wind: 'strong', play: 'yes' },
    { outlook: 'sunny', temperature: 'mild', humidity: 'high', wind: 'weak', play: 'no' },
    { outlook: 'sunny', temperature: 'cool', humidity: 'normal', wind: 'weak', play: 'yes' },
    { outlook: 'rain', temperature: 'mild', humidity: 'normal', wind: 'weak', play: 'yes' },
    { outlook: 'sunny', temperature: 'mild', humidity: 'normal', wind: 'strong', play: 'yes' },
    { outlook: 'overcast', temperature: 'mild', humidity: 'high', wind: 'strong', play: 'yes' },
    { outlook: 'overcast', temperature: 'hot', humidity: 'normal', wind: 'weak', play: 'yes' },
    { outlook: 'rain', temperature: 'mild', humidity: 'high', wind: 'strong', play: 'no' }
  ]

  puts '=== Decision Tree Training ==='
  tree = DecisionTree.new(max_depth: 5)
  tree.train(training_data, target: :play)

  puts "\n=== Decision Tree Structure ==="
  puts tree.visualize

  puts "\n=== Predictions ==="
  test_samples = [
    { outlook: 'sunny', temperature: 'mild', humidity: 'low', wind: 'weak' },
    { outlook: 'rain', temperature: 'hot', humidity: 'high', wind: 'strong' },
    { outlook: 'overcast', temperature: 'cool', humidity: 'normal', wind: 'weak' }
  ]

  test_samples.each do |sample|
    prediction = tree.predict(sample)
    puts "#{sample} => #{prediction}"
  end

  puts "\n=== Extracted Rules ==="
  rules = tree.extract_rules
  rules.each_with_index do |rule, i|
    puts "#{i + 1}. #{rule}"
  end

  puts "\n=== Training Accuracy ==="
  accuracy = tree.accuracy(training_data)
  puts "Accuracy: #{(accuracy * 100).round(2)}%"

  # エントロピーと情報利得の例
  puts "\n=== Information Theory Example ==="
  dataset = DataSet.new(training_data, :play)

  puts "Initial entropy: #{tree.send(:entropy, dataset.target_values).round(3)}"

  %i[outlook temperature humidity wind].each do |attribute|
    gain = tree.send(:information_gain, dataset, attribute)
    puts "Information gain for '#{attribute}': #{gain.round(3)}"
  end
end
