class ConfigManager
  def initialize
    @configs = {}
    @environments = %w[development staging production]
    @default_values = {}
  end

  def load_config(file_path, environment = 'development')
    # ファイル読み込み
    unless File.exist?(file_path)
      puts "Config file not found: #{file_path}"
      return false
    end

    content = File.read(file_path)

    # YAMLパース
    begin
      data = YAML.load(content)
    rescue StandardError => e
      puts "Failed to parse YAML: #{e.message}"
      return false
    end

    # 環境別設定の取得
    env_config = {}

    # デフォルト値
    if data['default']
      data['default'].each do |key, value|
        env_config[key] = value
        @default_values[key] = value
      end
    end

    # 環境固有の値でオーバーライド
    if data[environment]
      data[environment].each do |key, value|
        env_config[key] = value
      end
    end

    # 設定の検証
    env_config.each do |key, value|
      # 必須項目チェック
      if key.end_with?('_required') && value.nil?
        puts "Required config missing: #{key}"
        return false
      end

      # 型チェック
      if (key.include?('port') || key.include?('timeout')) && (!value.is_a?(Integer) || value < 0)
        puts "Invalid number for #{key}: #{value}"
        return false
      end

      if (key.include?('url') || key.include?('host')) && (!value.is_a?(String) || value.empty?)
        puts "Invalid string for #{key}: #{value}"
        return false
      end

      next unless key.include?('enabled') || key.include?('debug')

      unless [true, false].include?(value)
        puts "Invalid boolean for #{key}: #{value}"
        return false
      end
    end

    # 環境変数による上書き
    env_config.each do |key, value|
      env_key = "APP_#{key.upcase}"
      next unless ENV[env_key]

      # 型変換
      env_config[key] = if value.is_a?(Integer)
                          ENV[env_key].to_i
                        elsif [true, false].include?(value)
                          ENV[env_key].downcase == 'true'
                        else
                          ENV[env_key]
                        end
    end

    # テンプレート変数の展開
    env_config.each do |key, value|
      next unless value.is_a?(String) && value.include?('${')

      # 変数置換
      value.scan(/\${([^}]+)}/).each do |match|
        var_name = match[0]
        if env_config[var_name]
          value = value.gsub("${#{var_name}}", env_config[var_name].to_s)
        else
          puts "Undefined variable: ${#{var_name}}"
          return false
        end
      end
      env_config[key] = value
    end

    @configs[environment] = env_config
    true
  end

  def get(key, environment = 'development')
    return @default_values[key] unless @configs[environment]

    value = @configs[environment][key]

    # ネストされたキーのサポート
    if key.include?('.')
      parts = key.split('.')
      current = @configs[environment]

      parts.each do |part|
        return @default_values[key] unless current.is_a?(Hash) && current[part]

        current = current[part]
      end

      value = current
    end

    value
  end

  def set(key, value, environment = 'development')
    @configs[environment] = {} unless @configs[environment]

    # ネストされたキーのサポート
    if key.include?('.')
      parts = key.split('.')
      current = @configs[environment]

      # 最後の要素以外を辿る
      parts[0..-2].each do |part|
        current[part] ||= {}
        current = current[part]
      end

      current[parts.last] = value
    else
      @configs[environment][key] = value
    end
  end

  def reload
    # 全環境の設定をリロード
    @environments.each do |env|
      if @configs[env]
        # 設定ファイルのパスを覚えていないので再読み込みできない
        puts "Cannot reload #{env} config"
      end
    end
  end

  def export(environment = 'development', format = 'yaml')
    unless @configs[environment]
      puts "No config for environment: #{environment}"
      return nil
    end

    case format
    when 'yaml'
      @configs[environment].to_yaml
    when 'json'
      JSON.pretty_generate(@configs[environment])
    when 'env'
      lines = []
      @configs[environment].each do |key, value|
        lines << "APP_#{key.upcase}=#{value}"
      end
      lines.join("\n")
    else
      puts "Unknown format: #{format}"
      nil
    end
  end

  def validate_all
    valid = true

    @configs.each do |env, config|
      puts "Validating #{env}..."

      # 循環参照チェック
      config.each do |key, value|
        if value.is_a?(String) && value.include?("${#{key}}")
          puts "Circular reference detected: #{key}"
          valid = false
        end
      end

      # 未定義の参照チェック
      config.each do |key, value|
        next unless value.is_a?(String) && value.include?('${')

        value.scan(/\${([^}]+)}/).each do |match|
          var_name = match[0]
          unless config[var_name]
            puts "Undefined reference: ${#{var_name}} in #{key}"
            valid = false
          end
        end
      end
    end

    valid
  end
end
