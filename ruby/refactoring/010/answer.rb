require 'csv'
require 'time'

class FileProcessor
  MAX_FILE_SIZE = 10 * 1024 * 1024 # 10MB

  def process_csv(file_path)
    file_validator = FileValidator.new(file_path)
    validation_result = file_validator.validate

    return validation_result unless validation_result[:success]

    csv_processor = CSVProcessor.new(file_path)
    csv_processor.process
  end
end

class FileValidator
  def initialize(file_path)
    @file_path = file_path
  end

  def validate
    return error_response('File not found') unless File.exist?(@file_path)
    return error_response('File too large') if file_too_large?
    return error_response('Empty file') if file_empty?

    { success: true }
  end

  private

  def file_too_large?
    File.size(@file_path) > FileProcessor::MAX_FILE_SIZE
  end

  def file_empty?
    File.zero?(@file_path)
  end

  def error_response(message)
    { success: false, error: "Error: #{message}" }
  end
end

class CSVProcessor
  def initialize(file_path)
    @file_path = file_path
    @results = []
    @errors = []
  end

  def process
    CSV.foreach(@file_path, headers: true).with_index(2) do |row, line_number|
      process_row(row, line_number)
    end

    build_response
  rescue CSV::MalformedCSVError => e
    { success: false, error: "Error: Invalid CSV format - #{e.message}" }
  end

  private

  def process_row(row, line_number)
    validator = RowValidator.new(row, line_number)
    errors = validator.validate

    if errors.any?
      @errors.concat(errors)
      return
    end

    transformer = RowTransformer.new(row)
    transformed_row = transformer.transform

    @results << transformed_row
  rescue StandardError => e
    @errors << "Line #{line_number}: #{e.message}"
  end

  def build_response
    {
      success: true,
      data: @results,
      errors: @errors,
      total_lines: @results.count + @errors.count,
      processed: @results.count,
      failed: @errors.count
    }
  end
end

class RowValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  def initialize(row, line_number)
    @row = row
    @line_number = line_number
    @errors = []
  end

  def validate
    validate_email if @row['email']
    validate_age if @row['age']
    @errors
  end

  private

  def validate_email
    return if @row['email'].match?(EMAIL_REGEX)

    @errors << "Line #{@line_number}: Invalid email format"
  end

  def validate_age
    age = @row['age'].to_i
    @errors << "Line #{@line_number}: Invalid age" if age < 0
  end
end

class RowTransformer
  def initialize(row)
    @row = row.to_h
  end

  def transform
    transformed = @row.dup

    transform_name(transformed)
    transform_date(transformed)

    transformed
  end

  private

  def transform_name(row)
    row['name'] = row['name'].upcase if row['name']
  end

  def transform_date(row)
    return unless row['created_at']

    row['created_at'] = parse_date(row['created_at'])
  end

  def parse_date(date_string)
    Time.parse(date_string).strftime('%Y-%m-%d')
  rescue ArgumentError
    raise 'Invalid date format'
  end
end
