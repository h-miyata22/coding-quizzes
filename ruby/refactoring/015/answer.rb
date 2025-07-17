class AppConfig
  class << self
    def database
      ConfigBuilder.new(:database, environment).build
    end

    def redis
      ConfigBuilder.new(:redis, environment).build
    end

    def api_endpoints
      ConfigBuilder.new(:api_endpoints, environment).build
    end

    private

    def environment
      @environment ||= Environment.new(ENV['RAILS_ENV'])
    end
  end
end

class Environment
  VALID_ENVIRONMENTS = %w[production staging test development].freeze

  attr_reader :name

  def initialize(env_name)
    @name = normalize(env_name)
  end

  def production?
    @name == 'production'
  end

  def staging?
    @name == 'staging'
  end

  def test?
    @name == 'test'
  end

  def development?
    @name == 'development'
  end

  private

  def normalize(env_name)
    env = env_name&.downcase
    VALID_ENVIRONMENTS.include?(env) ? env : 'development'
  end
end

class ConfigBuilder
  def initialize(config_type, environment)
    @config_type = config_type
    @environment = environment
  end

  def build
    config_class.new(@environment).to_h
  end

  private

  def config_class
    case @config_type
    when :database then DatabaseConfig
    when :redis then RedisConfig
    when :api_endpoints then ApiEndpointsConfig
    else
      raise ArgumentError, "Unknown config type: #{@config_type}"
    end
  end
end

class BaseConfig
  def initialize(environment)
    @environment = environment
  end

  def to_h
    base_config.merge(environment_specific_config)
  end

  protected

  def base_config
    {}
  end

  def environment_specific_config
    send("#{@environment.name}_config")
  rescue NoMethodError
    development_config
  end

  def env_value(key, default = nil)
    value = ENV[key]
    return default if value.nil? || value.empty?

    value
  end

  def env_int(key, default = nil)
    value = env_value(key)
    value ? value.to_i : default
  end
end

class DatabaseConfig < BaseConfig
  DEFAULT_PORT = 5432

  protected

  def base_config
    {
      port: env_int('DB_PORT', DEFAULT_PORT),
      username: env_value('DB_USER', default_username),
      password: env_value('DB_PASSWORD', default_password)
    }
  end

  def production_config
    {
      host: env_value('DB_HOST', 'prod-db.example.com'),
      database: env_value('DB_NAME', 'myapp_production'),
      pool: env_int('DB_POOL', 20),
      timeout: 5000
    }
  end

  def staging_config
    {
      host: env_value('DB_HOST', 'staging-db.example.com'),
      database: env_value('DB_NAME', 'myapp_staging'),
      pool: env_int('DB_POOL', 10),
      timeout: 5000
    }
  end

  def test_config
    {
      host: 'localhost',
      database: 'myapp_test',
      username: 'test_user',
      password: 'test_password',
      pool: 5,
      timeout: 1000
    }
  end

  def development_config
    {
      host: env_value('DB_HOST', 'localhost'),
      database: env_value('DB_NAME', 'myapp_development'),
      pool: env_int('DB_POOL', 5),
      timeout: 5000
    }
  end

  private

  def default_username
    @environment.development? ? 'dev_user' : 'app_user'
  end

  def default_password
    @environment.development? ? 'dev_password' : nil
  end
end

class RedisConfig < BaseConfig
  DEFAULT_PORT = 6379

  protected

  def base_config
    {
      port: env_int('REDIS_PORT', DEFAULT_PORT)
    }
  end

  def production_config
    {
      host: env_value('REDIS_HOST', 'prod-redis.example.com'),
      db: 0,
      password: env_value('REDIS_PASSWORD')
    }
  end

  def staging_config
    {
      host: env_value('REDIS_HOST', 'staging-redis.example.com'),
      db: 1,
      password: env_value('REDIS_PASSWORD')
    }
  end

  def development_config
    {
      host: env_value('REDIS_HOST', 'localhost'),
      db: 2,
      password: nil
    }
  end

  alias test_config development_config
end

class ApiEndpointsConfig < BaseConfig
  API_ENDPOINTS = {
    production: {
      payment_api: 'https://api.payment.com/v1',
      shipping_api: 'https://api.shipping.com/v2',
      notification_api: 'https://api.notification.com/v1'
    },
    staging: {
      payment_api: 'https://staging-api.payment.com/v1',
      shipping_api: 'https://staging-api.shipping.com/v2',
      notification_api: 'https://staging-api.notification.com/v1'
    },
    development: {
      payment_api: 'http://localhost:3001',
      shipping_api: 'http://localhost:3002',
      notification_api: 'http://localhost:3003'
    }
  }.freeze

  def to_h
    endpoints = API_ENDPOINTS[@environment.name.to_sym] || API_ENDPOINTS[:development]

    endpoints.transform_values do |default_url|
      env_key = url_to_env_key(default_url)
      env_value(env_key, default_url)
    end
  end

  private

  def url_to_env_key(url)
    service = url.match(%r{//(.*?)\.(\w+)\.(com|localhost)})[2]
    "#{service.upcase}_API_URL"
  rescue StandardError
    nil
  end
end
