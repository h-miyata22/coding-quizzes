class DocumentProcessor
  def process_document(document)
    case document[:type]
    when 'text'
      process_text_document(document)
    when 'image'
      process_image_document(document)
    when 'video'
      process_video_document(document)
    when 'audio'
      process_audio_document(document)
    when 'pdf'
      process_pdf_document(document)
    else
      puts "Unknown document type: #{document[:type]}"
    end
  end

  def analyze_document(document)
    case document[:type]
    when 'text'
      analyze_text(document)
    when 'image'
      analyze_image(document)
    when 'video'
      analyze_video(document)
    when 'audio'
      analyze_audio(document)
    when 'pdf'
      analyze_pdf(document)
    else
      puts "Cannot analyze unknown document type: #{document[:type]}"
    end
  end

  def generate_metadata(document)
    metadata = {}

    case document[:type]
    when 'text'
      metadata[:word_count] = document[:content].split.length
      metadata[:character_count] = document[:content].length
      metadata[:encoding] = 'UTF-8'

    when 'image'
      metadata[:width] = document[:width] || 0
      metadata[:height] = document[:height] || 0
      metadata[:format] = document[:format] || 'unknown'
      metadata[:color_depth] = document[:color_depth] || 24

    when 'video'
      metadata[:duration] = document[:duration] || 0
      metadata[:resolution] = "#{document[:width]}x#{document[:height]}"
      metadata[:frame_rate] = document[:frame_rate] || 30
      metadata[:codec] = document[:codec] || 'h264'

    when 'audio'
      metadata[:duration] = document[:duration] || 0
      metadata[:bitrate] = document[:bitrate] || 128
      metadata[:sample_rate] = document[:sample_rate] || 44_100
      metadata[:channels] = document[:channels] || 2

    when 'pdf'
      metadata[:page_count] = document[:page_count] || 0
      metadata[:version] = document[:pdf_version] || '1.4'
      metadata[:encrypted] = document[:encrypted] || false

    else
      metadata[:error] = 'Unknown document type'
    end

    metadata
  end

  def calculate_storage_size(document)
    case document[:type]
    when 'text'
      document[:content].length

    when 'image'
      width = document[:width] || 0
      height = document[:height] || 0
      color_depth = document[:color_depth] || 24
      (width * height * color_depth) / 8

    when 'video'
      width = document[:width] || 0
      height = document[:height] || 0
      frame_rate = document[:frame_rate] || 30
      duration = document[:duration] || 0
      color_depth = 24
      (width * height * frame_rate * duration * color_depth) / 8

    when 'audio'
      sample_rate = document[:sample_rate] || 44_100
      channels = document[:channels] || 2
      duration = document[:duration] || 0
      bit_depth = 16
      (sample_rate * channels * duration * bit_depth) / 8

    when 'pdf'
      page_count = document[:page_count] || 0
      page_count * 50_000

    else
      0
    end
  end

  def generate_preview(document)
    case document[:type]
    when 'text'
      content = document[:content] || ''
      content.length > 100 ? content[0..100] + '...' : content

    when 'image'
      "Image preview: #{document[:width]}x#{document[:height]} #{document[:format]}"

    when 'video'
      "Video preview: #{document[:duration]}s #{document[:width]}x#{document[:height]}"

    when 'audio'
      "Audio preview: #{document[:duration]}s #{document[:channels]}ch"

    when 'pdf'
      "PDF preview: #{document[:page_count]} pages"

    else
      'No preview available'
    end
  end

  def validate_document(document)
    errors = []

    case document[:type]
    when 'text'
      errors << 'Content is missing' if document[:content].nil? || document[:content].empty?

    when 'image'
      errors << 'Width must be positive' if document[:width].nil? || document[:width] <= 0
      errors << 'Height must be positive' if document[:height].nil? || document[:height] <= 0
      errors << 'Invalid format' unless %w[jpg png gif bmp].include?(document[:format])

    when 'video'
      errors << 'Width must be positive' if document[:width].nil? || document[:width] <= 0
      errors << 'Height must be positive' if document[:height].nil? || document[:height] <= 0
      errors << 'Duration must be positive' if document[:duration].nil? || document[:duration] <= 0
      errors << 'Invalid codec' unless %w[h264 h265 vp9].include?(document[:codec])

    when 'audio'
      errors << 'Duration must be positive' if document[:duration].nil? || document[:duration] <= 0
      errors << 'Invalid sample rate' unless [22_050, 44_100, 48_000, 96_000].include?(document[:sample_rate])
      errors << 'Invalid channel count' unless [1, 2, 6, 8].include?(document[:channels])

    when 'pdf'
      errors << 'Page count must be positive' if document[:page_count].nil? || document[:page_count] <= 0
      errors << 'Invalid PDF version' unless document[:pdf_version] =~ /^\d+\.\d+$/

    else
      errors << "Unknown document type: #{document[:type]}"
    end

    errors
  end

  private

  def process_text_document(document)
    puts "Processing text document: #{document[:content][0..50]}..."
  end

  def process_image_document(document)
    puts "Processing image document: #{document[:width]}x#{document[:height]}"
  end

  def process_video_document(document)
    puts "Processing video document: #{document[:duration]}s"
  end

  def process_audio_document(document)
    puts "Processing audio document: #{document[:duration]}s"
  end

  def process_pdf_document(document)
    puts "Processing PDF document: #{document[:page_count]} pages"
  end

  def analyze_text(document)
    puts 'Analyzing text: word count, readability'
  end

  def analyze_image(document)
    puts 'Analyzing image: colors, composition'
  end

  def analyze_video(document)
    puts 'Analyzing video: scenes, motion'
  end

  def analyze_audio(document)
    puts 'Analyzing audio: frequency, loudness'
  end

  def analyze_pdf(document)
    puts 'Analyzing PDF: structure, fonts'
  end
end
