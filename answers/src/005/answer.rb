class EmailNotifier
  def initialize(type, user)
    @user = user
    @type = type
  end

  def send_email
    email = ::EmailGenerator.new.execute(@type, @user)
    puts "Sending email: #{email}"
    true
  rescue => e
    puts "Error sending email: #{e.backtrace.join("\n")}"
    false
  end
end

class EmailGenerator
  def initialize
    @templates = ::EmailTemplate.new
  end

  def execute(type, user)
    template = @templates.find(type)
    generate_mail(template, user)
  end

  private

  def generate_body(body_template, user)
    body_template.gsub(/\{\{\w+\}\}/) { |match| key = match[2..-3].to_sym; user[key] }
  end

  def format(preferences)
    if preferences && preferences[:html_emails] == false
      'text'
    else
      'html'
    end
  end

  def generate_mail(template, user)
    mail = {}
    mail[:to] = user[:email]
    mail[:from] = template[:from]
    mail[:subject] = template[:subject]
    mail[:body] = generate_body(template[:body_template], user)
    mail[:template] = template[:html_template]
    mail[:format] = format(user[:preferences])
    mail
  end
end

class EmailTemplate
  def initialize
    @templates = {}
    define_templates
  end

  def find(type)
    raise "Template not found: #{type}" unless @templates[type.to_sym]

    @templates[type.to_sym]
  end

  private

  def define_templates
    @templates = {
      welcome: {
        subject: 'Welcome to Our Service!',
        from: 'noreply@example.com',
        body_template: "Hello {{name}},\n\nThank you for joining us!",
        html_template: 'welcome.html'
      },
      password_reset: {
        subject: 'Password Reset Request',
        from: 'security@example.com',
        body_template: "Hello {{name}},\n\nClick here to reset your password.",
        html_template: 'password_reset.html'
      },
      order_confirmation: {
        subject: "Order Confirmation {{order_id}}",
        from: 'orders@example.com',
        body_template: "Hello {{name}},\n\nYour order has been confirmed.",
        html_template: 'order.html'
      },
      newsletter: {
        subject: 'Monthly Newsletter',
        from: 'newsletter@example.com',
        body_template: "Hello {{name}},\n\nHere's our monthly update.",
        html_template: 'newsletter.html'
      }
    }
  end
end



user = {
  name: 'John Doe',
  email: 'john.doe@example.com',
  order_id: 123456,
  preferences: {
    html_emails: false
  }
}

EmailNotifier.new('welcome', user).send_email
EmailNotifier.new('dummy', user).send_email