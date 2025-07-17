class DocumentGenerator
  def generate(type, data)
    document_class = DocumentFactory.create(type)
    return 'Unknown document type' unless document_class

    document = document_class.new(data)
    formatter = FormatterFactory.create(data[:format])

    formatter.format(document.render)
  end
end

class DocumentFactory
  DOCUMENT_TYPES = {
    invoice: InvoiceDocument,
    report: ReportDocument,
    letter: LetterDocument,
    certificate: CertificateDocument
  }.freeze

  def self.create(type)
    DOCUMENT_TYPES[type.to_sym]
  end
end

class FormatterFactory
  def self.create(format)
    case format&.to_sym
    when :pdf
      PdfFormatter.new
    else
      PlainTextFormatter.new
    end
  end
end

class Document
  def initialize(data)
    @data = data
  end

  def render
    raise NotImplementedError, 'Subclasses must implement render'
  end

  protected

  attr_reader :data

  def format_header(title)
    <<~HEADER
      #{title}
      #{'=' * title.length}

    HEADER
  end
end

class InvoiceDocument < Document
  def render
    StringIO.new.tap do |content|
      content.puts format_header('INVOICE')
      content.puts invoice_details
      content.puts
      content.puts 'Items:'
      content.puts format_items
      content.puts
      content.puts "Total: $#{calculate_total}"
    end.string
  end

  private

  def invoice_details
    <<~DETAILS
      Invoice Number: #{data[:invoice_number]}
      Date: #{data[:date]}
      Customer: #{data[:customer_name]}
    DETAILS
  end

  def format_items
    data[:items].map { |item| format_item(item) }.join("\n")
  end

  def format_item(item)
    subtotal = item[:quantity] * item[:price]
    "  #{item[:name]} x#{item[:quantity]} @ $#{item[:price]} = $#{subtotal}"
  end

  def calculate_total
    data[:items].sum { |item| item[:quantity] * item[:price] }
  end
end

class ReportDocument < Document
  def render
    StringIO.new.tap do |content|
      content.puts format_header('REPORT')
      content.puts report_metadata
      content.puts 'Summary:'
      content.puts data[:summary]
      content.puts
      content.puts format_sections if data[:sections]
    end.string
  end

  private

  def report_metadata
    <<~META
      Title: #{data[:title]}
      Generated: #{Time.now}

    META
  end

  def format_sections
    data[:sections].map.with_index(1) do |section, index|
      format_section(section, index)
    end.join("\n")
  end

  def format_section(section, index)
    <<~SECTION
      #{index}. #{section[:heading]}
      #{section[:content]}

    SECTION
  end
end

class LetterDocument < Document
  def render
    <<~LETTER
      #{data[:sender_address]}

      #{data[:date]}

      #{data[:recipient_name]}
      #{data[:recipient_address]}

      Dear #{data[:recipient_name]},

      #{data[:body]}

      Sincerely,
      #{data[:sender_name]}
    LETTER
  end
end

class CertificateDocument < Document
  def render
    title = "CERTIFICATE OF #{data[:type].upcase}"

    <<~CERTIFICATE
      #{format_header(title)}
      This is to certify that

          #{data[:recipient_name]}

      #{data[:achievement]}

      Date: #{data[:date]}
      Issued by: #{data[:issuer]}
    CERTIFICATE
  end
end

class Formatter
  def format(content)
    raise NotImplementedError, 'Subclasses must implement format'
  end
end

class PlainTextFormatter < Formatter
  def format(content)
    content
  end
end

class PdfFormatter < Formatter
  def format(content)
    # PDF生成のダミー実装
    "PDF: #{content}"
  end
end
