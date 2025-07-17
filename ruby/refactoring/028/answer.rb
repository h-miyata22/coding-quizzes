class DocumentProcessor
  def initialize
    @processor_visitor = ProcessorVisitor.new
    @analyzer_visitor = AnalyzerVisitor.new
    @metadata_visitor = MetadataVisitor.new
    @storage_visitor = StorageSizeVisitor.new
    @preview_visitor = PreviewVisitor.new
    @validator_visitor = ValidatorVisitor.new
  end

  def process_document(document_data)
    document = DocumentFactory.create(document_data)
    document.accept(@processor_visitor)
  end

  def analyze_document(document_data)
    document = DocumentFactory.create(document_data)
    document.accept(@analyzer_visitor)
  end

  def generate_metadata(document_data)
    document = DocumentFactory.create(document_data)
    document.accept(@metadata_visitor)
  end

  def calculate_storage_size(document_data)
    document = DocumentFactory.create(document_data)
    document.accept(@storage_visitor)
  end

  def generate_preview(document_data)
    document = DocumentFactory.create(document_data)
    document.accept(@preview_visitor)
  end

  def validate_document(document_data)
    document = DocumentFactory.create(document_data)
    document.accept(@validator_visitor)
  end
end

# Visitor Pattern Implementation
class DocumentVisitor
  def visit_text_document(document)
    raise NotImplementedError
  end

  def visit_image_document(document)
    raise NotImplementedError
  end

  def visit_video_document(document)
    raise NotImplementedError
  end

  def visit_audio_document(document)
    raise NotImplementedError
  end

  def visit_pdf_document(document)
    raise NotImplementedError
  end
end

class ProcessorVisitor < DocumentVisitor
  def visit_text_document(document)
    puts "Processing text document: #{document.content[0..50]}..."
  end

  def visit_image_document(document)
    puts "Processing image document: #{document.dimensions}"
  end

  def visit_video_document(document)
    puts "Processing video document: #{document.duration}s"
  end

  def visit_audio_document(document)
    puts "Processing audio document: #{document.duration}s"
  end

  def visit_pdf_document(document)
    puts "Processing PDF document: #{document.page_count} pages"
  end
end

class AnalyzerVisitor < DocumentVisitor
  def visit_text_document(document)
    puts 'Analyzing text: word count, readability'
    TextAnalysis.new(document).perform
  end

  def visit_image_document(document)
    puts 'Analyzing image: colors, composition'
    ImageAnalysis.new(document).perform
  end

  def visit_video_document(document)
    puts 'Analyzing video: scenes, motion'
    VideoAnalysis.new(document).perform
  end

  def visit_audio_document(document)
    puts 'Analyzing audio: frequency, loudness'
    AudioAnalysis.new(document).perform
  end

  def visit_pdf_document(document)
    puts 'Analyzing PDF: structure, fonts'
    PdfAnalysis.new(document).perform
  end
end

class MetadataVisitor < DocumentVisitor
  def visit_text_document(document)
    TextMetadataExtractor.new(document).extract
  end

  def visit_image_document(document)
    ImageMetadataExtractor.new(document).extract
  end

  def visit_video_document(document)
    VideoMetadataExtractor.new(document).extract
  end

  def visit_audio_document(document)
    AudioMetadataExtractor.new(document).extract
  end

  def visit_pdf_document(document)
    PdfMetadataExtractor.new(document).extract
  end
end

class StorageSizeVisitor < DocumentVisitor
  def visit_text_document(document)
    TextSizeCalculator.new(document).calculate
  end

  def visit_image_document(document)
    ImageSizeCalculator.new(document).calculate
  end

  def visit_video_document(document)
    VideoSizeCalculator.new(document).calculate
  end

  def visit_audio_document(document)
    AudioSizeCalculator.new(document).calculate
  end

  def visit_pdf_document(document)
    PdfSizeCalculator.new(document).calculate
  end
end

class PreviewVisitor < DocumentVisitor
  def visit_text_document(document)
    TextPreviewGenerator.new(document).generate
  end

  def visit_image_document(document)
    ImagePreviewGenerator.new(document).generate
  end

  def visit_video_document(document)
    VideoPreviewGenerator.new(document).generate
  end

  def visit_audio_document(document)
    AudioPreviewGenerator.new(document).generate
  end

  def visit_pdf_document(document)
    PdfPreviewGenerator.new(document).generate
  end
end

class ValidatorVisitor < DocumentVisitor
  def visit_text_document(document)
    TextDocumentValidator.new(document).validate
  end

  def visit_image_document(document)
    ImageDocumentValidator.new(document).validate
  end

  def visit_video_document(document)
    VideoDocumentValidator.new(document).validate
  end

  def visit_audio_document(document)
    AudioDocumentValidator.new(document).validate
  end

  def visit_pdf_document(document)
    PdfDocumentValidator.new(document).validate
  end
end

# Document Hierarchy
class Document
  def accept(visitor)
    raise NotImplementedError
  end
end

class TextDocument < Document
  attr_reader :content

  def initialize(data)
    @content = data[:content] || ''
  end

  def accept(visitor)
    visitor.visit_text_document(self)
  end
end

class ImageDocument < Document
  attr_reader :width, :height, :format, :color_depth

  def initialize(data)
    @width = data[:width] || 0
    @height = data[:height] || 0
    @format = data[:format] || 'unknown'
    @color_depth = data[:color_depth] || 24
  end

  def accept(visitor)
    visitor.visit_image_document(self)
  end

  def dimensions
    "#{@width}x#{@height}"
  end
end

class VideoDocument < Document
  attr_reader :width, :height, :duration, :frame_rate, :codec

  def initialize(data)
    @width = data[:width] || 0
    @height = data[:height] || 0
    @duration = data[:duration] || 0
    @frame_rate = data[:frame_rate] || 30
    @codec = data[:codec] || 'h264'
  end

  def accept(visitor)
    visitor.visit_video_document(self)
  end

  def resolution
    "#{@width}x#{@height}"
  end
end

class AudioDocument < Document
  attr_reader :duration, :bitrate, :sample_rate, :channels

  def initialize(data)
    @duration = data[:duration] || 0
    @bitrate = data[:bitrate] || 128
    @sample_rate = data[:sample_rate] || 44_100
    @channels = data[:channels] || 2
  end

  def accept(visitor)
    visitor.visit_audio_document(self)
  end
end

class PdfDocument < Document
  attr_reader :page_count, :pdf_version, :encrypted

  def initialize(data)
    @page_count = data[:page_count] || 0
    @pdf_version = data[:pdf_version] || '1.4'
    @encrypted = data[:encrypted] || false
  end

  def accept(visitor)
    visitor.visit_pdf_document(self)
  end
end

# Factory for Document Creation
class DocumentFactory
  DOCUMENT_TYPES = {
    'text' => TextDocument,
    'image' => ImageDocument,
    'video' => VideoDocument,
    'audio' => AudioDocument,
    'pdf' => PdfDocument
  }.freeze

  def self.create(data)
    document_class = DOCUMENT_TYPES[data[:type]]
    raise UnsupportedDocumentType, "Unknown document type: #{data[:type]}" unless document_class

    document_class.new(data)
  end
end

# Metadata Extractors
class MetadataExtractor
  def initialize(document)
    @document = document
  end

  def extract
    raise NotImplementedError
  end
end

class TextMetadataExtractor < MetadataExtractor
  def extract
    {
      word_count: @document.content.split.length,
      character_count: @document.content.length,
      encoding: 'UTF-8'
    }
  end
end

class ImageMetadataExtractor < MetadataExtractor
  def extract
    {
      width: @document.width,
      height: @document.height,
      format: @document.format,
      color_depth: @document.color_depth
    }
  end
end

class VideoMetadataExtractor < MetadataExtractor
  def extract
    {
      duration: @document.duration,
      resolution: @document.resolution,
      frame_rate: @document.frame_rate,
      codec: @document.codec
    }
  end
end

class AudioMetadataExtractor < MetadataExtractor
  def extract
    {
      duration: @document.duration,
      bitrate: @document.bitrate,
      sample_rate: @document.sample_rate,
      channels: @document.channels
    }
  end
end

class PdfMetadataExtractor < MetadataExtractor
  def extract
    {
      page_count: @document.page_count,
      version: @document.pdf_version,
      encrypted: @document.encrypted
    }
  end
end

# Size Calculators
class SizeCalculator
  def initialize(document)
    @document = document
  end

  def calculate
    raise NotImplementedError
  end
end

class TextSizeCalculator < SizeCalculator
  def calculate
    @document.content.length
  end
end

class ImageSizeCalculator < SizeCalculator
  def calculate
    (@document.width * @document.height * @document.color_depth) / 8
  end
end

class VideoSizeCalculator < SizeCalculator
  COLOR_DEPTH = 24

  def calculate
    (@document.width * @document.height * @document.frame_rate *
     @document.duration * COLOR_DEPTH) / 8
  end
end

class AudioSizeCalculator < SizeCalculator
  BIT_DEPTH = 16

  def calculate
    (@document.sample_rate * @document.channels *
     @document.duration * BIT_DEPTH) / 8
  end
end

class PdfSizeCalculator < SizeCalculator
  BYTES_PER_PAGE = 50_000

  def calculate
    @document.page_count * BYTES_PER_PAGE
  end
end

# Preview Generators
class PreviewGenerator
  def initialize(document)
    @document = document
  end

  def generate
    raise NotImplementedError
  end
end

class TextPreviewGenerator < PreviewGenerator
  MAX_PREVIEW_LENGTH = 100

  def generate
    content = @document.content
    if content.length > MAX_PREVIEW_LENGTH
      content[0..MAX_PREVIEW_LENGTH] + '...'
    else
      content
    end
  end
end

class ImagePreviewGenerator < PreviewGenerator
  def generate
    "Image preview: #{@document.dimensions} #{@document.format}"
  end
end

class VideoPreviewGenerator < PreviewGenerator
  def generate
    "Video preview: #{@document.duration}s #{@document.resolution}"
  end
end

class AudioPreviewGenerator < PreviewGenerator
  def generate
    "Audio preview: #{@document.duration}s #{@document.channels}ch"
  end
end

class PdfPreviewGenerator < PreviewGenerator
  def generate
    "PDF preview: #{@document.page_count} pages"
  end
end

# Validators
class DocumentValidator
  def initialize(document)
    @document = document
  end

  def validate
    raise NotImplementedError
  end
end

class TextDocumentValidator < DocumentValidator
  def validate
    errors = []
    errors << 'Content is missing' if @document.content.nil? || @document.content.empty?
    errors
  end
end

class ImageDocumentValidator < DocumentValidator
  VALID_FORMATS = %w[jpg png gif bmp].freeze

  def validate
    errors = []
    errors << 'Width must be positive' if @document.width <= 0
    errors << 'Height must be positive' if @document.height <= 0
    errors << 'Invalid format' unless VALID_FORMATS.include?(@document.format)
    errors
  end
end

class VideoDocumentValidator < DocumentValidator
  VALID_CODECS = %w[h264 h265 vp9].freeze

  def validate
    errors = []
    errors << 'Width must be positive' if @document.width <= 0
    errors << 'Height must be positive' if @document.height <= 0
    errors << 'Duration must be positive' if @document.duration <= 0
    errors << 'Invalid codec' unless VALID_CODECS.include?(@document.codec)
    errors
  end
end

class AudioDocumentValidator < DocumentValidator
  VALID_SAMPLE_RATES = [22_050, 44_100, 48_000, 96_000].freeze
  VALID_CHANNEL_COUNTS = [1, 2, 6, 8].freeze

  def validate
    errors = []
    errors << 'Duration must be positive' if @document.duration <= 0
    errors << 'Invalid sample rate' unless VALID_SAMPLE_RATES.include?(@document.sample_rate)
    errors << 'Invalid channel count' unless VALID_CHANNEL_COUNTS.include?(@document.channels)
    errors
  end
end

class PdfDocumentValidator < DocumentValidator
  VERSION_PATTERN = /^\d+\.\d+$/.freeze

  def validate
    errors = []
    errors << 'Page count must be positive' if @document.page_count <= 0
    errors << 'Invalid PDF version' unless @document.pdf_version =~ VERSION_PATTERN
    errors
  end
end

# Analysis Classes
class DocumentAnalysis
  def initialize(document)
    @document = document
  end

  def perform
    raise NotImplementedError
  end
end

class TextAnalysis < DocumentAnalysis
  def perform
    {
      word_count: @document.content.split.length,
      readability_score: calculate_readability
    }
  end

  private

  def calculate_readability
    # Simplified readability calculation
    words = @document.content.split.length
    sentences = @document.content.split(/[.!?]/).length
    return 0 if sentences == 0

    words.to_f / sentences
  end
end

class ImageAnalysis < DocumentAnalysis
  def perform
    {
      aspect_ratio: calculate_aspect_ratio,
      megapixels: calculate_megapixels
    }
  end

  private

  def calculate_aspect_ratio
    return 0 if @document.height == 0

    @document.width.to_f / @document.height
  end

  def calculate_megapixels
    (@document.width * @document.height) / 1_000_000.0
  end
end

class VideoAnalysis < DocumentAnalysis
  def perform
    {
      total_frames: @document.duration * @document.frame_rate,
      resolution_class: classify_resolution
    }
  end

  private

  def classify_resolution
    pixels = @document.width * @document.height
    case pixels
    when 0...921_600 then 'SD'
    when 921_600...2_073_600 then 'HD'
    else 'UHD'
    end
  end
end

class AudioAnalysis < DocumentAnalysis
  def perform
    {
      quality_class: classify_quality,
      stereo: @document.channels > 1
    }
  end

  private

  def classify_quality
    case @document.sample_rate
    when 0...44_100 then 'Low'
    when 44_100...48_000 then 'Standard'
    else 'High'
    end
  end
end

class PdfAnalysis < DocumentAnalysis
  def perform
    {
      document_size: classify_size,
      security_level: @document.encrypted ? 'Encrypted' : 'Open'
    }
  end

  private

  def classify_size
    case @document.page_count
    when 0...10 then 'Small'
    when 10...100 then 'Medium'
    else 'Large'
    end
  end
end

# Custom Exceptions
class UnsupportedDocumentType < StandardError; end
