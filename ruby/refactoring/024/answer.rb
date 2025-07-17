require 'yaml'
require 'json'

class ConfigManager
  def initialize
    @config_store = ConfigStore.new
    @loader = ConfigLoader.new
    @validator = ConfigValidator.new
    @exporter = ConfigExporter.new
  end

  def load_config(file_path, environment: 'development')
    config_source = ConfigSource.new(file_path: file_path, environment: environment)

    result = @loader.load(config_source)
    return false unless result.success?

    config = result.config

    validation_result = @validator.validate(config)
    return false unless validation_result.valid?

    @config_store.store(environment, config)
    true
  end

  def get(key, environment: 'development')
    config = @config_store.get(environment)
    return nil unless config

    ConfigAccessor.new(config).get(key)
  end

  def set(key, value, environment: 'development')
    config = @config_store.get_or_create(environment)
    ConfigAccessor.new(config).set(key, value)
  end

  def reload
    @config_store.reload_all(@loader)
  end

  def export(environment: 'development', format: 'yaml')
    config = @config_store.get(environment)
    return nil unless config

    @exporter.export(config, format)
  end

  def validate_all
    @config_store.all.all? do |environment, config|
      result = @validator.validate(config)
      puts "Validation failed for #{environment}: #{result.errors.join(', ')}" unless result.valid?
      result.valid?
    end
  end
end

class ConfigLoader
  def initialize
    @parser = YamlParser.new
    @overlay = EnvironmentOverlay.new
    @interpolator = VariableInterpolator.new
    @env_overrider = EnvironmentVariableOverrider.new
  end

  def load(source)
    content = read_file(source.file_path)
    return LoadResult.failure('File not found') unless content

    raw_config = @parser.parse(content)
    return LoadResult.failure('Failed to parse file') unless raw_config

    config_data = @overlay.apply(raw_config, source.environment)
    config_data = @env_overrider.override(config_data)

    interpolation_result = @interpolator.interpolate(config_data)
    return LoadResult.failure(interpolation_result.error) unless interpolation_result.success?

    config = Configuration.new(
      data: interpolation_result.data,
      environment: source.environment,
      source: source
    )

    LoadResult.success(config)
  end

  private

  def read_file(path)
    return nil unless File.exist?(path)

    File.read(path)
  end
end

class Configuration
  attr_reader :data, :environment, :source

  def initialize(data:, environment:, source:)
    @data = data.freeze
    @environment = environment
    @source = source
  end

  def get(key)
    @data[key]
  end

  def with_data(new_data)
    Configuration.new(
      data: new_data,
      environment: @environment,
      source: @source
    )
  end
end

class ConfigSource
  attr_reader :file_path, :environment

  def initialize(file_path:, environment:)
    @file_path = file_path
    @environment = environment
  end
end

class LoadResult
  attr_reader :config, :error

  def self.success(config)
    new(success: true, config: config)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def initialize(success:, config: nil, error: nil)
    @success = success
    @config = config
    @error = error
  end

  def success?
    @success
  end
end

class YamlParser
  def parse(content)
    YAML.safe_load(content, aliases: true)
  rescue StandardError
    nil
  end
end

class EnvironmentOverlay
  def apply(raw_config, environment)
    base_config = raw_config['default'] || {}
    env_config = raw_config[environment] || {}

    deep_merge(base_config, env_config)
  end

  private

  def deep_merge(base, overlay)
    base.merge(overlay) do |_key, base_val, overlay_val|
      if base_val.is_a?(Hash) && overlay_val.is_a?(Hash)
        deep_merge(base_val, overlay_val)
      else
        overlay_val
      end
    end
  end
end

class EnvironmentVariableOverrider
  def override(config_data)
    overridden = config_data.dup

    config_data.each do |key, value|
      env_key = "APP_#{key.upcase}"
      env_value = ENV[env_key]

      next unless env_value

      overridden[key] = cast_value(env_value, value)
    end

    overridden
  end

  private

  def cast_value(env_value, original_value)
    TypeCaster.new.cast(env_value, original_value.class)
  end
end

class TypeCaster
  def cast(value, target_class)
    case target_class.name
    when 'Integer'
      value.to_i
    when 'TrueClass', 'FalseClass'
      value.downcase == 'true'
    when 'Float'
      value.to_f
    else
      value
    end
  end
end

class VariableInterpolator
  def interpolate(config_data)
    interpolated = {}
    unresolved = Set.new

    config_data.each do |key, value|
      result = interpolate_value(value, config_data, unresolved)
      if unresolved.include?(key)
        return InterpolationResult.failure("Circular reference: #{unresolved.to_a.join(', ')}")
      end
      return result unless result.success?

      interpolated[key] = result.value
    end

    InterpolationResult.success(interpolated)
  end

  private

  def interpolate_value(value, context, unresolved, depth = 0)
    return InterpolationResult.failure('Max interpolation depth exceeded') if depth > 10

    return InterpolationResult.success(value) unless value.is_a?(String)

    interpolated = value.dup

    value.scan(/\${([^}]+)}/).each do |match|
      var_name = match[0]

      return InterpolationResult.failure("Undefined variable: ${#{var_name}}") unless context[var_name]

      return InterpolationResult.failure("Circular reference detected: #{var_name}") if unresolved.include?(var_name)

      unresolved.add(var_name)
      sub_result = interpolate_value(context[var_name], context, unresolved, depth + 1)
      unresolved.delete(var_name)

      return sub_result unless sub_result.success?

      interpolated.gsub!("${#{var_name}}", sub_result.value.to_s)
    end

    InterpolationResult.success(interpolated)
  end
end

class InterpolationResult
  attr_reader :value, :error

  def self.success(value)
    new(success: true, value: value)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def initialize(success:, value: nil, error: nil)
    @success = success
    @value = value
    @error = error
  end

  def success?
    @success
  end

  def data
    @value
  end
end

class ConfigValidator
  def initialize
    @validators = [
      RequiredFieldValidator.new,
      TypeValidator.new,
      ReferenceValidator.new
    ]
  end

  def validate(config)
    errors = []

    @validators.each do |validator|
      result = validator.validate(config)
      errors.concat(result.errors) unless result.valid?
    end

    ValidationResult.new(errors: errors)
  end
end

class Validator
  def validate(config)
    raise NotImplementedError
  end
end

class RequiredFieldValidator < Validator
  def validate(config)
    errors = []

    config.data.each do |key, value|
      errors << "Required config missing: #{key}" if key.end_with?('_required') && value.nil?
    end

    ValidationResult.new(errors: errors)
  end
end

class TypeValidator < Validator
  def validate(config)
    errors = []
    schema = ConfigSchema.new

    config.data.each do |key, value|
      expected_type = schema.type_for(key)
      next unless expected_type

      unless value.is_a?(expected_type[:class])
        errors << "Invalid type for #{key}: expected #{expected_type[:name]}, got #{value.class}"
      end

      if expected_type[:validator] && !expected_type[:validator].call(value)
        errors << "Invalid value for #{key}: #{value}"
      end
    end

    ValidationResult.new(errors: errors)
  end
end

class ConfigSchema
  def initialize
    @type_rules = {
      /port|timeout/ => { class: Integer, name: 'Integer', validator: ->(v) { v >= 0 } },
      /url|host/ => { class: String, name: 'String', validator: ->(v) { !v.empty? } },
      /enabled|debug/ => { class: [TrueClass, FalseClass], name: 'Boolean' }
    }
  end

  def type_for(key)
    @type_rules.each do |pattern, type_info|
      return normalize_type_info(type_info) if key.match?(pattern)
    end
    nil
  end

  private

  def normalize_type_info(type_info)
    if type_info[:class].is_a?(Array)
      {
        class: ->(v) { type_info[:class].any? { |c| v.is_a?(c) } },
        name: type_info[:name],
        validator: type_info[:validator]
      }
    else
      type_info
    end
  end
end

class ReferenceValidator < Validator
  def validate(config)
    errors = []

    config.data.each do |key, value|
      next unless value.is_a?(String) && value.include?('${')

      value.scan(/\${([^}]+)}/).each do |match|
        var_name = match[0]
        errors << "Undefined reference: ${#{var_name}} in #{key}" unless config.data[var_name]
      end
    end

    ValidationResult.new(errors: errors)
  end
end

class ValidationResult
  attr_reader :errors

  def initialize(errors:)
    @errors = errors
  end

  def valid?
    @errors.empty?
  end
end

class ConfigAccessor
  def initialize(config)
    @config = config
  end

  def get(key)
    if key.include?('.')
      get_nested(key)
    else
      @config.get(key)
    end
  end

  def set(key, value)
    data = @config.data.dup

    if key.include?('.')
      set_nested(data, key, value)
    else
      data[key] = value
    end

    @config.with_data(data)
  end

  private

  def get_nested(key)
    keys = key.split('.')
    current = @config.data

    keys.each do |k|
      return nil unless current.is_a?(Hash) && current.key?(k)

      current = current[k]
    end

    current
  end

  def set_nested(data, key, value)
    keys = key.split('.')
    current = data

    keys[0..-2].each do |k|
      current[k] ||= {}
      current = current[k]
    end

    current[keys.last] = value
  end
end

class ConfigStore
  def initialize
    @configs = {}
  end

  def store(environment, config)
    @configs[environment] = config
  end

  def get(environment)
    @configs[environment]
  end

  def get_or_create(environment)
    @configs[environment] ||= Configuration.new(
      data: {},
      environment: environment,
      source: ConfigSource.new(file_path: nil, environment: environment)
    )
  end

  def all
    @configs
  end

  def reload_all(loader)
    @configs.each do |environment, config|
      next unless config.source.file_path

      result = loader.load(config.source)
      store(environment, result.config) if result.success?
    end
  end
end

class ConfigExporter
  def initialize
    @formatters = {
      'yaml' => YamlFormatter.new,
      'json' => JsonFormatter.new,
      'env' => EnvFormatter.new
    }
  end

  def export(config, format)
    formatter = @formatters[format]
    return nil unless formatter

    formatter.format(config.data)
  end
end

class Formatter
  def format(data)
    raise NotImplementedError
  end
end

class YamlFormatter < Formatter
  def format(data)
    data.to_yaml
  end
end

class JsonFormatter < Formatter
  def format(data)
    JSON.pretty_generate(data)
  end
end

class EnvFormatter < Formatter
  def format(data)
    data.map do |key, value|
      "APP_#{key.upcase}=#{value}"
    end.join("\n")
  end
end
