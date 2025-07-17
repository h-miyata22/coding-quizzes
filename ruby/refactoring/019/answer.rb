class DataProcessor
  def process_data(input_file, output_file, options = {})
    pipeline = DataPipeline.new
                           .add_stage(FileReader.new(input_file))
                           .add_stage(ValidationStage.new(options))
                           .add_stage(TransformationStage.new(options))
                           .add_stage(FilteringStage.new(options))
                           .add_stage(SortingStage.new(options))
                           .add_stage(FileWriter.new(output_file))

    result = pipeline.execute

    StatisticsReporter.new(result).report
    result.to_h
  end
end

class DataPipeline
  def initialize
    @stages = []
  end

  def add_stage(stage)
    @stages << stage
    self
  end

  def execute
    initial_context = ProcessingContext.new

    @stages.reduce(initial_context) do |context, stage|
      stage.process(context)
    end
  end
end

class ProcessingContext
  attr_reader :data, :statistics

  def initialize(data: [], statistics: Statistics.new)
    @data = data
    @statistics = statistics
  end

  def with_data(new_data)
    ProcessingContext.new(data: new_data, statistics: @statistics)
  end

  def with_statistics(stats_update)
    updated_stats = @statistics.merge(stats_update)
    ProcessingContext.new(data: @data, statistics: updated_stats)
  end
end

class Statistics
  attr_reader :total_lines, :invalid_lines, :output_lines

  def initialize(total_lines: 0, invalid_lines: 0, output_lines: 0)
    @total_lines = total_lines
    @invalid_lines = invalid_lines
    @output_lines = output_lines
  end

  def merge(updates)
    Statistics.new(
      total_lines: updates[:total_lines] || @total_lines,
      invalid_lines: updates[:invalid_lines] || @invalid_lines,
      output_lines: updates[:output_lines] || @output_lines
    )
  end

  def to_h
    {
      total: @total_lines,
      invalid: @invalid_lines,
      output: @output_lines
    }
  end
end

class FileReader
  def initialize(file_path)
    @file_path = file_path
  end

  def process(context)
    lines = File.readlines(@file_path).map(&:strip)

    context
      .with_data(lines)
      .with_statistics(total_lines: lines.length)
  end
end

class ValidationStage
  def initialize(options)
    @validators = build_validators(options)
  end

  def process(context)
    validation_result = DataValidator.new(@validators).validate(context.data)

    context
      .with_data(validation_result.valid_data)
      .with_statistics(invalid_lines: validation_result.invalid_count)
  end

  private

  def build_validators(options)
    validators = [EmptyLineValidator.new]

    validators << LengthValidator.new(options[:max_length]) if options[:max_length]
    validators << PatternValidator.new(options[:pattern]) if options[:pattern]

    validators
  end
end

class ValidationResult
  attr_reader :valid_data, :invalid_count

  def initialize(valid_data:, invalid_count:)
    @valid_data = valid_data
    @invalid_count = invalid_count
  end
end

class DataValidator
  def initialize(validators)
    @validators = validators
  end

  def validate(data)
    results = data.partition { |line| valid?(line) }

    ValidationResult.new(
      valid_data: results[0],
      invalid_count: results[1].length
    )
  end

  private

  def valid?(line)
    @validators.all? { |validator| validator.valid?(line) }
  end
end

class Validator
  def valid?(line)
    raise NotImplementedError
  end
end

class EmptyLineValidator < Validator
  def valid?(line)
    !line.empty?
  end
end

class LengthValidator < Validator
  def initialize(max_length)
    @max_length = max_length
  end

  def valid?(line)
    line.length <= @max_length
  end
end

class PatternValidator < Validator
  def initialize(pattern)
    @pattern = pattern
  end

  def valid?(line)
    line.match?(@pattern)
  end
end

class TransformationStage
  def initialize(options)
    @transformers = build_transformers(options)
  end

  def process(context)
    transformed_data = context.data.map { |line| transform(line) }
    context.with_data(transformed_data)
  end

  private

  def build_transformers(options)
    transformers = []

    transformers << CaseTransformer.new(:upcase) if options[:uppercase]
    transformers << CaseTransformer.new(:downcase) if options[:lowercase]
    transformers << PrefixTransformer.new(options[:prefix]) if options[:prefix]
    transformers << SuffixTransformer.new(options[:suffix]) if options[:suffix]

    if options[:replace_from] && options[:replace_to]
      transformers << ReplaceTransformer.new(options[:replace_from], options[:replace_to])
    end

    transformers
  end

  def transform(line)
    @transformers.reduce(line) { |result, transformer| transformer.transform(result) }
  end
end

class Transformer
  def transform(line)
    raise NotImplementedError
  end
end

class CaseTransformer < Transformer
  def initialize(method)
    @method = method
  end

  def transform(line)
    line.send(@method)
  end
end

class PrefixTransformer < Transformer
  def initialize(prefix)
    @prefix = prefix
  end

  def transform(line)
    @prefix + line
  end
end

class SuffixTransformer < Transformer
  def initialize(suffix)
    @suffix = suffix
  end

  def transform(line)
    line + @suffix
  end
end

class ReplaceTransformer < Transformer
  def initialize(from, to)
    @from = from
    @to = to
  end

  def transform(line)
    line.gsub(@from, @to)
  end
end

class FilteringStage
  def initialize(options)
    @filters = build_filters(options)
  end

  def process(context)
    filtered_data = apply_filters(context.data)
    context.with_data(filtered_data)
  end

  private

  def build_filters(options)
    filters = []

    filters << UniqueFilter.new if options[:unique]
    filters << KeywordFilter.new(:include, options[:include_keyword]) if options[:include_keyword]
    filters << KeywordFilter.new(:exclude, options[:exclude_keyword]) if options[:exclude_keyword]

    filters
  end

  def apply_filters(data)
    @filters.reduce(data) { |result, filter| filter.apply(result) }
  end
end

class Filter
  def apply(data)
    raise NotImplementedError
  end
end

class UniqueFilter < Filter
  def apply(data)
    data.uniq
  end
end

class KeywordFilter < Filter
  def initialize(mode, keyword)
    @mode = mode
    @keyword = keyword
  end

  def apply(data)
    case @mode
    when :include
      data.select { |line| line.include?(@keyword) }
    when :exclude
      data.reject { |line| line.include?(@keyword) }
    else
      data
    end
  end
end

class SortingStage
  def initialize(options)
    @enabled = options[:sort]
  end

  def process(context)
    return context unless @enabled

    sorted_data = context.data.sort
    context.with_data(sorted_data)
  end
end

class FileWriter
  def initialize(file_path)
    @file_path = file_path
  end

  def process(context)
    File.open(@file_path, 'w') do |file|
      context.data.each { |line| file.puts(line) }
    end

    context.with_statistics(output_lines: context.data.length)
  end
end

class StatisticsReporter
  def initialize(context)
    @statistics = context.statistics
  end

  def report
    puts 'Processing completed:'
    puts "  Total lines: #{@statistics.total_lines}"
    puts "  Invalid lines: #{@statistics.invalid_lines}"
    puts "  Output lines: #{@statistics.output_lines}"
  end
end
