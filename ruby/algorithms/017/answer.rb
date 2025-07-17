require 'set'

class Document
  attr_reader :id, :content, :tokens, :token_positions

  def initialize(id, content)
    @id = id
    @content = content
    @tokens = tokenize(content)
    @token_positions = build_position_index(@tokens)
  end

  def term_frequency(term)
    @tokens.count(term).to_f / @tokens.size
  end

  def contains_phrase?(phrase_tokens)
    return false if phrase_tokens.empty?
    return true if phrase_tokens.size == 1 && @token_positions.key?(phrase_tokens[0])

    # 最初の単語の位置を取得
    first_positions = @token_positions[phrase_tokens[0]] || []

    first_positions.any? do |start_pos|
      # フレーズの残りの単語が連続しているか確認
      phrase_tokens[1..-1].each_with_index.all? do |token, i|
        positions = @token_positions[token] || []
        positions.include?(start_pos + i + 1)
      end
    end
  end

  private

  def tokenize(text)
    text.downcase.scan(/\w+/)
  end

  def build_position_index(tokens)
    positions = Hash.new { |h, k| h[k] = [] }

    tokens.each_with_index do |token, position|
      positions[token] << position
    end

    positions
  end
end

class PostingList
  attr_reader :term, :documents

  def initialize(term)
    @term = term
    @documents = {} # doc_id => { positions: [], tf: 0.0 }
  end

  def add_document(doc_id, positions, tf)
    @documents[doc_id] = { positions: positions, tf: tf }
  end

  def document_frequency
    @documents.size
  end

  def get_documents
    @documents.keys
  end
end

class InvertedIndex
  def initialize
    @index = {} # term => PostingList
    @documents = {} # doc_id => Document
    @total_documents = 0
  end

  def add_document(document)
    @documents[document.id] = document
    @total_documents += 1

    # 各単語の出現位置を記録
    document.token_positions.each do |term, positions|
      @index[term] ||= PostingList.new(term)
      tf = document.term_frequency(term)
      @index[term].add_document(document.id, positions, tf)
    end
  end

  def get_posting_list(term)
    @index[term.downcase]
  end

  def idf(term)
    posting_list = get_posting_list(term)
    return 0 unless posting_list

    Math.log(@total_documents.to_f / posting_list.document_frequency)
  end

  def tf_idf(term, doc_id)
    posting_list = get_posting_list(term)
    return 0 unless posting_list

    doc_info = posting_list.documents[doc_id]
    return 0 unless doc_info

    doc_info[:tf] * idf(term)
  end

  def get_document(doc_id)
    @documents[doc_id]
  end

  def statistics
    {
      total_documents: @total_documents,
      total_terms: @index.size,
      avg_document_length: calculate_avg_document_length,
      index_size: calculate_index_size
    }
  end

  private

  def calculate_avg_document_length
    return 0 if @documents.empty?

    total_tokens = @documents.values.sum { |doc| doc.tokens.size }
    total_tokens.to_f / @documents.size
  end

  def calculate_index_size
    # 簡易的なサイズ推定
    @index.values.sum do |posting_list|
      posting_list.documents.sum do |_, info|
        info[:positions].size * 4 + 8 # 位置情報とTF値
      end
    end
  end
end

class SearchEngine
  def initialize
    @index = InvertedIndex.new
  end

  def add_document(doc_id, content)
    document = Document.new(doc_id, content)
    @index.add_document(document)
  end

  def search(query, limit: 10)
    query_terms = tokenize(query)
    return [] if query_terms.empty?

    # 各ドキュメントのスコアを計算
    scores = calculate_scores(query_terms)

    # スコアでソートして上位を返す
    scores.sort_by { |_, score| -score }
          .first(limit)
          .map { |doc_id, score| [doc_id, score.round(2)] }
  end

  def boolean_search(query)
    # 簡易的なブーリアン検索パーサー
    tokens = query.split(/\s+/)
    result_set = nil
    current_op = :and
    negate_next = false

    i = 0
    while i < tokens.size
      token = tokens[i]

      case token.upcase
      when 'AND'
        current_op = :and
      when 'OR'
        current_op = :or
      when 'NOT'
        negate_next = true
      else
        # 単語の検索
        posting_list = @index.get_posting_list(token.downcase)
        term_docs = posting_list ? Set.new(posting_list.get_documents) : Set.new

        if negate_next
          all_docs = Set.new(@index.instance_variable_get(:@documents).keys)
          term_docs = all_docs - term_docs
          negate_next = false
        end

        if result_set.nil?
          result_set = term_docs
        else
          case current_op
          when :and
            result_set &= term_docs
          when :or
            result_set |= term_docs
          end
        end
      end

      i += 1
    end

    result_set ? result_set.to_a.sort : []
  end

  def phrase_search(phrase)
    phrase_tokens = tokenize(phrase)
    return [] if phrase_tokens.empty?

    # 最初の単語を含むドキュメントを取得
    first_posting = @index.get_posting_list(phrase_tokens[0])
    return [] unless first_posting

    results = []

    first_posting.get_documents.each do |doc_id|
      document = @index.get_document(doc_id)
      results << doc_id if document.contains_phrase?(phrase_tokens)
    end

    results.sort
  end

  def more_like_this(doc_id, limit: 5)
    document = @index.get_document(doc_id)
    return [] unless document

    # ドキュメントの重要な単語を抽出（TF-IDFが高い順）
    important_terms = document.tokens.uniq.map do |term|
      [term, @index.tf_idf(term, doc_id)]
    end.sort_by { |_, score| -score }.first(10).map(&:first)

    # 重要な単語で検索
    scores = calculate_scores(important_terms)

    # 元のドキュメントを除外してソート
    scores.delete(doc_id)
    scores.sort_by { |_, score| -score }
          .first(limit)
          .map { |id, score| [id, score.round(2)] }
  end

  def index_statistics
    @index.statistics
  end

  private

  def tokenize(text)
    text.downcase.scan(/\w+/)
  end

  def calculate_scores(query_terms)
    scores = Hash.new(0.0)

    # クエリの各単語についてスコアを計算
    query_terms.each do |term|
      posting_list = @index.get_posting_list(term)
      next unless posting_list

      idf = @index.idf(term)

      posting_list.documents.each do |doc_id, doc_info|
        # TF-IDFスコア
        scores[doc_id] += doc_info[:tf] * idf
      end
    end

    # 正規化（ドキュメント長による調整）
    scores.each do |doc_id, score|
      document = @index.get_document(doc_id)
      next unless document

      # ドキュメントが短い場合はスコアを上げる
      length_factor = Math.log(1 + 1.0 / document.tokens.size)
      scores[doc_id] = score * (1 + length_factor)
    end

    scores
  end
end

# テスト
if __FILE__ == $0
  engine = SearchEngine.new

  # サンプルドキュメントを追加
  documents = {
    'doc1' => 'Ruby is a dynamic programming language with a focus on simplicity',
    'doc2' => 'Ruby programming is fun and productive',
    'doc3' => 'I love Ruby and Python programming languages',
    'doc4' => 'Web development with Ruby on Rails framework',
    'doc5' => 'Python is another dynamic programming language',
    'doc6' => 'JavaScript is used for web development',
    'doc7' => 'Ruby gems are packages for Ruby programming'
  }

  documents.each { |id, content| engine.add_document(id, content) }

  puts '=== Single Term Search ==='
  results = engine.search('Ruby')
  puts "Search 'Ruby':"
  results.each { |doc_id, score| puts "  #{doc_id}: #{score}" }

  puts "\n=== Multi-term Search ==="
  results = engine.search('programming language')
  puts "Search 'programming language':"
  results.each { |doc_id, score| puts "  #{doc_id}: #{score}" }

  puts "\n=== Boolean Search ==="
  results = engine.boolean_search('Ruby AND programming')
  puts "Ruby AND programming: #{results}"

  results = engine.boolean_search('Ruby OR Python')
  puts "Ruby OR Python: #{results}"

  results = engine.boolean_search('programming NOT Python')
  puts "programming NOT Python: #{results}"

  puts "\n=== Phrase Search ==="
  results = engine.phrase_search('Ruby programming')
  puts "\"Ruby programming\": #{results}"

  results = engine.phrase_search('dynamic programming language')
  puts "\"dynamic programming language\": #{results}"

  puts "\n=== More Like This ==="
  similar = engine.more_like_this('doc1', limit: 3)
  puts 'Documents similar to doc1:'
  similar.each { |doc_id, score| puts "  #{doc_id}: #{score}" }

  puts "\n=== Index Statistics ==="
  stats = engine.index_statistics
  stats.each { |k, v| puts "#{k}: #{v}" }
end
