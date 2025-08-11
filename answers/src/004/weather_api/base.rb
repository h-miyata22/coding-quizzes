require 'net/http'
require 'json'

module WeatherAPI
  class Base
    BASE_URL = 'http://localhost:80'
    ERROR_MESSAGES = {
      '404' => 'City not found',
      '500' => 'Server error'
    }.freeze

    def initialize(path)
      @path = path
    end

    def execute(params = {})
      response = connect_to_api(params)

      case response.code
      when '200'
        data = JSON.parse(response.body)
        display_result(data, params)
      else
        ERROR_MESSAGES[response.code] || 'Unknown error'
      end

    rescue StandardError => e
      "Error: #{e.message}"
    end

    private

    def connect_to_api(params = {})
      validate_params(params)

      uri = URI("#{BASE_URL}#{@path}")
      uri.query = URI.encode_www_form(params)
      Net::HTTP.get_response(uri)
    end

    def validate_params(params)
      raise NotImplementedError, 'Subclass must implement validate_params'
    end

    def display_result(data)
      raise NotImplementedError, 'Subclass must implement display_result'
    end
  end
end