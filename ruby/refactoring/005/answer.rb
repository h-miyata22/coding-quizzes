class EmailNotifier
  def initialize
    @templates = EmailTemplates.new
  end

  def send_email(type, user)
    template = @templates.find(type)
    return false unless template

    mail = EmailBuilder.new(template, user).build
    deliver(mail)
  end

  private

  def deliver(mail)
    # 実際の送信処理（省略）
    puts "Sending email: #{mail}"
    true
  end
end

class EmailTemplates
  def initialize
    @templates = {}
    define_templates
  end

  def find(type)
    @templates[type.to_sym]
  end

  private

  def define_templates
    template :welcome do
      subject 'Welcome to Our Service!'
      from 'noreply@example.com'
      body_template "Hello {{name}},\n\nThank you for joining us!"
      html_template 'welcome.html'
    end

    template :password_reset do
      subject 'Password Reset Request'
      from 'security@example.com'
      body_template "Hello {{name}},\n\nClick here to reset your password."
      html_template 'password_reset.html'
    end

    template :order_confirmation do
      subject "Order Confirmation {{order_id}}"
      from 'orders@example.com'
      body_template "Hello {{name}},\n\nYour order has been confirmed."
      html_template 'order.html'
    end

    template :newsletter do
      subject 'Monthly Newsletter'
      from 'newsletter@example.com'
      body_template "Hello {{name}},\n\nHere's our monthly update."
      html_template 'newsletter.html'
    end
  end

  def template(name, &block)
    builder = TemplateBuilder.new
    builder.instance_eval(&block)
    @templates[name] = builder.build
  end
end

class TemplateBuilder
  def initialize
    @config = {}
  end

  def subject(text)
    @config[:subject] = text
  end

  def from(email)
    @config[:from] = email
  end

  def body_template(text)
    @config[:body_template] = text
  end

  def html_template(file)
    @config[:html_template] = file
  end

  def build
    EmailTemplate.new(@config)
  end
end

class EmailTemplate
  attr_reader :subject_template, :from, :body_template, :html_template

  def initialize(config)
    @subject_template = config[:subject]
    @from = config[:from]
    @body_template = config[:body_template]
    @html_template = config[:html_template]
  end

  def render_subject(data)
    interpolate(@subject_template, data)
  end

  def render_body(data)
    interpolate(@body_template, data)
  end

  private

  def interpolate(template, data)
    template.gsub(/\{\{(\w+)\}\}/) do |match|
      key = ::Regexp.last_match(1).to_sym
      data[key].to_s
    end
  end
end

class EmailBuilder
  def initialize(template, user)
    @template = template
    @user = user
  end

  def build
    {
      to: @user[:email],
      from: @template.from,
      subject: @template.render_subject(@user),
      body: @template.render_body(@user),
      template: @template.html_template,
      format: email_format
    }
  end

  private

  def email_format
    html_disabled? ? 'text' : 'html'
  end

  def html_disabled?
    @user.dig(:preferences, :html_emails) == false
  end
end
