class SearchEngine
  def initialize
    @document_store = DocumentStore.new
    @index = InvertedIndex.new
    @search_history = SearchHistory.new
    @query_parser = QueryParser.new
    @searcher = Searcher.new(@index)
    @indexer = Indexer.new(@index)
  end

  def add_document(id, title, content, tags: [])
    document = Document.new(
      id: id,
      title: title,
      content: content,
      tags: tags
    )

    return false unless @document_store.add(document)

    @indexer.index_document(document)
    true
  end

  def search(query_string, **options)
    query = @query_parser.parse(query_string)
    @search_history.record(query)

    search_context = SearchContext.new(
      query: query,
      options: SearchOptions.new(**options)
    )

    @searcher.search(search_context, @document_store)
  end

  def suggest(prefix, limit: 5)
    SuggestionEngine.new(@index).suggest(prefix, limit)
  end

  def get_stats
    Statistics.new(
      document_store: @document_store,
      index: @index,
      search_history: @search_history
    ).generate
  end

  def reindex
    @index.clear
    @document_store.all.each do |document|
      @indexer.index_document(document)
    end
  end
end

class Document
  attr_reader :id, :title, :content, :tags, :added_at

  def initialize(id:, title:, content:, tags:)
    @id = id
    @title = title
    @content = content
    @tags = tags.map(&:downcase)
    @added_at = Time.now
  end

  def ==(other)
    other.is_a?(Document) && other.id == id
  end
end

class DocumentStore
  def initialize
    @documents = {}
    @mutex = Mutex.new
  end

  def add(document)
    @mutex.synchronize do
      return false if @documents.key?(document.id)

      @documents[document.id] = document
      true
    end
  end

  def find(id)
    @documents[id]
  end

  def all
    @documents.values
  end

  def count
    @documents.size
  end
end

class InvertedIndex
  def initialize
    @index = Hash.new { |h, k| h[k] = [] }
    @mutex = Mutex.new
  end

  def add_entry(term, entry)
    @mutex.synchronize do
      @index[term] << entry
    end
  end

  def get_entries(term)
    @index[term].dup
  end

  def terms
    @index.keys
  end

  def clear
    @mutex.synchronize do
      @index.clear
    end
  end

  def term_frequency(term)
    @index[term].size
  end
end

class IndexEntry
  attr_reader :document_id, :field, :score, :position

  def initialize(document_id:, field:, score:, position: nil)
    @document_id = document_id
    @field = field
    @score = score
    @position = position
  end
end

class Indexer
  def initialize(index)
    @index = index
    @analyzer = TextAnalyzer.new
    @field_configs = {
      title: FieldConfig.new(score: 10),
      content: FieldConfig.new(score: 1),
      tag: FieldConfig.new(score: 5, prefix: 'tag:')
    }
  end

  def index_document(document)
    index_field(document.id, :title, document.title)
    index_field(document.id, :content, document.content)
    index_tags(document.id, document.tags)
  end

  private

  def index_field(document_id, field_type, text)
    config = @field_configs[field_type]
    tokens = @analyzer.analyze(text)

    tokens.each_with_index do |token, position|
      entry = IndexEntry.new(
        document_id: document_id,
        field: field_type.to_s,
        score: config.score,
        position: position
      )

      @index.add_entry(token, entry)
    end
  end

  def index_tags(document_id, tags)
    config = @field_configs[:tag]

    tags.each do |tag|
      term = "#{config.prefix}#{tag}"
      entry = IndexEntry.new(
        document_id: document_id,
        field: 'tag',
        score: config.score
      )

      @index.add_entry(term, entry)
    end
  end
end

class FieldConfig
  attr_reader :score, :prefix

  def initialize(score:, prefix: nil)
    @score = score
    @prefix = prefix
  end
end

class TextAnalyzer
  STOP_WORDS = %w[the a an and or but in on at to for].freeze

  def analyze(text)
    text.downcase
        .split(/\W+/)
        .reject { |word| word.empty? || STOP_WORDS.include?(word) }
        .uniq
  end
end

class Query
  attr_reader :terms, :operators

  def initialize(terms:, operators: [])
    @terms = terms
    @operators = operators
  end
end

class QueryParser
  def parse(query_string)
    parser = QueryTokenizer.new(query_string)
    tokens = parser.tokenize

    QueryBuilder.new(tokens).build
  end
end

class QueryTokenizer
  def initialize(query_string)
    @query_string = query_string
    @tokens = []
  end

  def tokenize
    current_token = ''
    in_quotes = false

    @query_string.chars.each do |char|
      case char
      when '"'
        in_quotes = !in_quotes
      when ' '
        if in_quotes
          current_token += char
        else
          add_token(current_token)
          current_token = ''
        end
      else
        current_token += char
      end
    end

    add_token(current_token)
    @tokens
  end

  private

  def add_token(token)
    return if token.empty?

    @tokens << if %w[AND OR NOT].include?(token)
                 QueryOperator.new(token)
               else
                 QueryTerm.new(token.downcase)
               end
  end
end

class QueryTerm
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class QueryOperator
  attr_reader :type

  def initialize(type)
    @type = type
  end
end

class QueryBuilder
  def initialize(tokens)
    @tokens = tokens
  end

  def build
    terms = @tokens.select { |t| t.is_a?(QueryTerm) }
    operators = @tokens.select { |t| t.is_a?(QueryOperator) }

    Query.new(terms: terms.map(&:value), operators: operators.map(&:type))
  end
end

class Searcher
  def initialize(index)
    @index = index
    @scorer = DocumentScorer.new
    @result_processor = ResultProcessor.new
  end

  def search(context, document_store)
    matching_entries = find_matching_entries(context.query)
    scored_results = @scorer.score(matching_entries, document_store)

    filtered_results = apply_filters(scored_results, context.options)
    sorted_results = apply_sorting(filtered_results, context.options)

    @result_processor.process(sorted_results, context.options)
  end

  private

  def find_matching_entries(query)
    entries = []

    query.terms.each do |term|
      entries.concat(@index.get_entries(term))
    end

    entries
  end

  def apply_filters(results, options)
    chain = FilterChain.new

    chain.add(TagFilter.new(options.tags)) if options.tags
    chain.add(DateRangeFilter.new(options.date_from, options.date_to)) if options.date_from || options.date_to

    chain.apply(results)
  end

  def apply_sorting(results, options)
    strategy = SortingStrategyFactory.create(options.sort_by, options.order)
    strategy.sort(results)
  end
end

class SearchContext
  attr_reader :query, :options

  def initialize(query:, options:)
    @query = query
    @options = options
  end
end

class SearchOptions
  attr_reader :tags, :date_from, :date_to, :sort_by, :order,
              :page, :per_page, :highlight

  def initialize(**options)
    @tags = options[:tags]
    @date_from = options[:date_from]
    @date_to = options[:date_to]
    @sort_by = options[:sort_by] || 'score'
    @order = options[:order] || 'desc'
    @page = options[:page] || 1
    @per_page = options[:per_page] || 10
    @highlight = options[:highlight] || false
  end
end

class DocumentScorer
  def score(entries, document_store)
    document_scores = Hash.new(0)

    entries.each do |entry|
      document_scores[entry.document_id] += entry.score
    end

    document_scores.map do |doc_id, score|
      document = document_store.find(doc_id)
      next unless document

      SearchResult.new(document: document, score: score)
    end.compact
  end
end

class SearchResult
  attr_reader :document, :score
  attr_accessor :highlighted_content

  def initialize(document:, score:)
    @document = document
    @score = score
  end
end

class FilterChain
  def initialize
    @filters = []
  end

  def add(filter)
    @filters << filter
  end

  def apply(results)
    @filters.reduce(results) do |filtered, filter|
      filter.apply(filtered)
    end
  end
end

class Filter
  def apply(results)
    raise NotImplementedError
  end
end

class TagFilter < Filter
  def initialize(tags)
    @tags = tags
  end

  def apply(results)
    results.select do |result|
      (result.document.tags & @tags).any?
    end
  end
end

class DateRangeFilter < Filter
  def initialize(from, to)
    @from = from
    @to = to
  end

  def apply(results)
    results.select do |result|
      date = result.document.added_at
      (!@from || date >= @from) && (!@to || date <= @to)
    end
  end
end

class SortingStrategyFactory
  def self.create(sort_by, order)
    case sort_by
    when 'date'
      DateSortingStrategy.new(order)
    when 'title'
      TitleSortingStrategy.new(order)
    else
      ScoreSortingStrategy.new(order)
    end
  end
end

class SortingStrategy
  def initialize(order)
    @ascending = (order == 'asc')
  end

  def sort(results)
    sorted = results.sort_by { |r| sort_key(r) }
    @ascending ? sorted : sorted.reverse
  end

  protected

  def sort_key(result)
    raise NotImplementedError
  end
end

class ScoreSortingStrategy < SortingStrategy
  def initialize(_order)
    super('desc') # Always descending for scores
  end

  protected

  def sort_key(result)
    result.score
  end
end

class DateSortingStrategy < SortingStrategy
  protected

  def sort_key(result)
    result.document.added_at
  end
end

class TitleSortingStrategy < SortingStrategy
  protected

  def sort_key(result)
    result.document.title
  end
end

class ResultProcessor
  def process(results, options)
    paginated = paginate(results, options.page, options.per_page)

    if options.highlight
      highlighter = Highlighter.new
      paginated[:results].each do |result|
        result.highlighted_content = highlighter.highlight(
          result.document.content,
          options.query_terms
        )
      end
    end

    SearchResponse.new(
      results: paginated[:results],
      total: results.size,
      page: options.page,
      per_page: options.per_page
    )
  end

  private

  def paginate(results, page, per_page)
    start_index = (page - 1) * per_page
    paginated_results = results[start_index, per_page] || []

    { results: paginated_results }
  end
end

class Highlighter
  def highlight(text, terms)
    highlighted = text.dup

    terms.each do |term|
      highlighted.gsub!(/#{Regexp.escape(term)}/i) do |match|
        "<mark>#{match}</mark>"
      end
    end

    highlighted
  end
end

class SearchResponse
  attr_reader :results, :total, :page, :per_page

  def initialize(results:, total:, page:, per_page:)
    @results = results
    @total = total
    @page = page
    @per_page = per_page
  end

  def to_h
    {
      results: @results,
      total: @total,
      page: @page,
      per_page: @per_page
    }
  end
end

class SuggestionEngine
  def initialize(index)
    @index = index
  end

  def suggest(prefix, limit)
    candidates = find_candidates(prefix)
    rank_candidates(candidates).take(limit)
  end

  private

  def find_candidates(prefix)
    prefix_lower = prefix.downcase

    @index.terms.select do |term|
      term.start_with?(prefix_lower) && !term.start_with?('tag:')
    end
  end

  def rank_candidates(candidates)
    candidates.sort_by { |term| -@index.term_frequency(term) }
  end
end

class SearchHistory
  def initialize
    @entries = []
    @mutex = Mutex.new
  end

  def record(query)
    @mutex.synchronize do
      @entries << HistoryEntry.new(query: query)
    end
  end

  def recent(limit = 10)
    @entries.last(limit).reverse
  end

  def query_frequency
    frequency = Hash.new(0)

    @entries.each do |entry|
      frequency[entry.query_string] += 1
    end

    frequency.sort_by { |_, count| -count }
  end

  def size
    @entries.size
  end
end

class HistoryEntry
  attr_reader :query, :timestamp

  def initialize(query:)
    @query = query
    @timestamp = Time.now
  end

  def query_string
    @query.terms.join(' ')
  end
end

class Statistics
  def initialize(document_store:, index:, search_history:)
    @document_store = document_store
    @index = index
    @search_history = search_history
  end

  def generate
    StatisticsReport.new(
      document_count: @document_store.count,
      indexed_words: count_indexed_words,
      tag_count: count_tags,
      search_count: @search_history.size,
      top_queries: @search_history.query_frequency.take(5)
    )
  end

  private

  def count_indexed_words
    @index.terms.reject { |term| term.start_with?('tag:') }.size
  end

  def count_tags
    @index.terms.select { |term| term.start_with?('tag:') }.size
  end
end

class StatisticsReport
  def initialize(document_count:, indexed_words:, tag_count:, search_count:, top_queries:)
    @document_count = document_count
    @indexed_words = indexed_words
    @tag_count = tag_count
    @search_count = search_count
    @top_queries = top_queries
  end

  def to_s
    <<~REPORT
      Search Engine Statistics:
        Documents: #{@document_count}
        Indexed words: #{@indexed_words}
        Tags: #{@tag_count}
        Search history: #{@search_count} queries
        Top queries:
      #{format_top_queries}
    REPORT
  end

  private

  def format_top_queries
    @top_queries.map do |query, count|
      "      #{query}: #{count} times"
    end.join("\n")
  end
end
