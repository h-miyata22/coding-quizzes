class DynamicConfig
  include ConfigMetaProgramming

  def initialize(data = {})
    @data = data
    @observers = []
    @validator = ConfigValidator.new
    setup_config_methods
  end

  def get_environment_config(env)
    method_name = "get_#{env}_config"

    raise ConfigError, "Unknown environment: #{env}" unless respond_to?(method_name, true)

    send(method_name)
  end

  def validate_config
    @validator.validate(@data)
  end

  def add_observer(&block)
    @observers << ConfigObserver.new(&block)
  end

  def to_h
    @data.dup
  end

  def method_missing(method_name, *args)
    if setter_method?(method_name)
      handle_setter(method_name, args.first)
    elsif getter_method?(method_name)
      handle_getter(method_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    config_method?(method_name) || super
  end

  private

  def setup_config_methods
    define_environment_methods
    define_validation_helpers
  end

  def define_environment_methods
    environments = %w[development staging production test]

    environments.each do |env|
      self.class.define_method("get_#{env}_config") do
        EnvironmentConfigFactory.create(env).to_h
      end
    end
  end

  def define_validation_helpers
    config_keys = %w[database_host database_port api_key cache_enabled log_level timeout]

    config_keys.each do |key|
      validator_method = "validate_#{key}"

      @validator.class.define_method(validator_method) do |value|
        validation_rule = ValidationRuleFactory.create(key)
        validation_rule.validate(value)
      end
    end
  end

  def setter_method?(method_name)
    method_name.to_s.end_with?('=')
  end

  def getter_method?(method_name)
    !setter_method?(method_name) && config_key?(method_name)
  end

  def config_method?(method_name)
    setter_method?(method_name) || getter_method?(method_name)
  end

  def config_key?(method_name)
    key_name = method_name.to_s.chomp('=')
    @data.key?(key_name) || standard_config_key?(key_name)
  end

  def standard_config_key?(key_name)
    %w[database_host database_port api_key cache_enabled log_level timeout].include?(key_name)
  end

  def handle_setter(method_name, value)
    key = method_name.to_s.chomp('=')
    old_value = @data[key]

    @data[key] = value
    notify_observers(key, old_value, value)

    value
  end

  def handle_getter(method_name)
    key = method_name.to_s
    @data[key]
  end

  def notify_observers(key, old_value, new_value)
    @observers.each do |observer|
      observer.notify(key, old_value, new_value)
    end
  end
end

module ConfigMetaProgramming
  def self.included(base)
    base.extend(ClassMethods)
    base.prepend(ConfigInterceptor)
  end

  module ClassMethods
    def config_accessor(*keys)
      keys.each do |key|
        define_config_getter(key)
        define_config_setter(key)
      end
    end

    private

    def define_config_getter(key)
      define_method(key) do
        @data[key.to_s]
      end
    end

    def define_config_setter(key)
      define_method("#{key}=") do |value|
        old_value = @data[key.to_s]
        @data[key.to_s] = value
        notify_observers(key.to_s, old_value, value)
        value
      end
    end
  end
end

module ConfigInterceptor
  def method_missing(method_name, *args, &block)
    if intercept_config_method?(method_name)
      with_logging(method_name) { super }
    else
      super
    end
  end

  private

  def intercept_config_method?(method_name)
    method_name.to_s.match?(/^(database_|api_|cache_|log_|timeout)/)
  end

  def with_logging(method_name)
    puts "[CONFIG] Accessing #{method_name}" if ENV['DEBUG_CONFIG']
    yield
  end
end

class ConfigObserver
  def initialize(&block)
    @callback = block || default_callback
  end

  def notify(key, old_value, new_value)
    @callback.call(key, old_value, new_value)
  end

  private

  def default_callback
    ->(key, _old_value, new_value) { puts "Config changed: #{key} = #{new_value}" }
  end
end

class ConfigValidator
  def validate(data)
    errors = []

    data.each do |key, value|
      validation_errors = validate_field(key, value)
      errors.concat(validation_errors)
    end

    errors
  end

  private

  def validate_field(key, value)
    validator_method = "validate_#{key}"

    if respond_to?(validator_method, true)
      send(validator_method, value)
    else
      []
    end
  end
end

class ValidationRuleFactory
  RULES = {
    'database_host' => HostValidationRule,
    'database_port' => PortValidationRule,
    'api_key' => ApiKeyValidationRule,
    'cache_enabled' => BooleanValidationRule,
    'log_level' => LogLevelValidationRule,
    'timeout' => TimeoutValidationRule
  }.freeze

  def self.create(field_name)
    rule_class = RULES[field_name] || NullValidationRule
    rule_class.new
  end
end

class ValidationRule
  def validate(value)
    raise NotImplementedError
  end
end

class HostValidationRule < ValidationRule
  def validate(value)
    return ['database_host is required'] if value.nil? || value.empty?

    []
  end
end

class PortValidationRule < ValidationRule
  VALID_RANGE = (1..65_535).freeze

  def validate(value)
    return ['database_port must be an integer between 1 and 65535'] unless valid_port?(value)

    []
  end

  private

  def valid_port?(value)
    value.is_a?(Integer) && VALID_RANGE.include?(value)
  end
end

class ApiKeyValidationRule < ValidationRule
  MIN_LENGTH = 8

  def validate(value)
    return ["api_key must be at least #{MIN_LENGTH} characters"] unless valid_api_key?(value)

    []
  end

  private

  def valid_api_key?(value)
    value.is_a?(String) && value.length >= MIN_LENGTH
  end
end

class BooleanValidationRule < ValidationRule
  def validate(value)
    return ['cache_enabled must be true or false'] unless [true, false].include?(value)

    []
  end
end

class LogLevelValidationRule < ValidationRule
  VALID_LEVELS = %w[debug info warn error].freeze

  def validate(value)
    return ["log_level must be one of: #{VALID_LEVELS.join(', ')}"] unless VALID_LEVELS.include?(value)

    []
  end
end

class TimeoutValidationRule < ValidationRule
  def validate(value)
    return ['timeout must be a positive integer'] unless valid_timeout?(value)

    []
  end

  private

  def valid_timeout?(value)
    value.is_a?(Integer) && value > 0
  end
end

class NullValidationRule < ValidationRule
  def validate(_value)
    []
  end
end

class EnvironmentConfigFactory
  ENVIRONMENT_CONFIGS = {
    'development' => DevelopmentConfig,
    'staging' => StagingConfig,
    'production' => ProductionConfig,
    'test' => TestConfig
  }.freeze

  def self.create(environment)
    config_class = ENVIRONMENT_CONFIGS[environment]
    raise ConfigError, "Unknown environment: #{environment}" unless config_class

    config_class.new
  end
end

class EnvironmentConfig
  def to_h
    raise NotImplementedError
  end
end

class DevelopmentConfig < EnvironmentConfig
  def to_h
    {
      'database_host' => 'localhost',
      'database_port' => 5432,
      'api_key' => 'dev_key_123',
      'cache_enabled' => false,
      'log_level' => 'debug',
      'timeout' => 30
    }
  end
end

class StagingConfig < EnvironmentConfig
  def to_h
    {
      'database_host' => 'staging.db.com',
      'database_port' => 5432,
      'api_key' => 'staging_key_456',
      'cache_enabled' => true,
      'log_level' => 'info',
      'timeout' => 60
    }
  end
end

class ProductionConfig < EnvironmentConfig
  def to_h
    {
      'database_host' => 'prod.db.com',
      'database_port' => 5432,
      'api_key' => 'prod_key_789',
      'cache_enabled' => true,
      'log_level' => 'warn',
      'timeout' => 120
    }
  end
end

class TestConfig < EnvironmentConfig
  def to_h
    {
      'database_host' => 'test.db.com',
      'database_port' => 5433,
      'api_key' => 'test_key_000',
      'cache_enabled' => false,
      'log_level' => 'debug',
      'timeout' => 10
    }
  end
end

class ConfigError < StandardError; end

# Example of using Around Alias pattern for method interception
class DynamicConfig
  alias original_method_missing method_missing

  def method_missing(method_name, *args)
    puts "[DEBUG] Method missing called: #{method_name}" if ENV['DEBUG_METHOD_MISSING']

    original_method_missing(method_name, *args)
  end
end
