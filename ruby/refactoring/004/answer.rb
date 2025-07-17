require 'net/http'
require 'json'

class WeatherAPI
  BASE_URL = 'https://api.weather.example.com/v1'

  ERROR_MESSAGES = {
    '404' => 'City not found',
    '500' => 'Server error'
  }.freeze

  def get_weather(city)
    return nil unless valid_city?(city)

    response = make_request('/current', city: city)
    return response unless response.is_a?(Hash)

    format_current_weather(city, response)
  end

  def get_forecast(city, days)
    return nil unless valid_forecast_params?(city, days)

    response = make_request('/forecast', city: city, days: days)
    return response unless response.is_a?(Hash)

    format_forecast(city, days, response)
  end

  private

  def valid_city?(city)
    !city.nil? && !city.empty?
  end

  def valid_forecast_params?(city, days)
    valid_city?(city) && days&.between?(1, 7)
  end

  def make_request(endpoint, params)
    uri = build_uri(endpoint, params)
    response = fetch_response(uri)

    parse_response(response)
  rescue StandardError => e
    "Error: #{e.message}"
  end

  def build_uri(endpoint, params)
    query_string = params.map { |k, v| "#{k}=#{v}" }.join('&')
    URI("#{BASE_URL}#{endpoint}?#{query_string}")
  end

  def fetch_response(uri)
    Net::HTTP.get_response(uri)
  end

  def parse_response(response)
    case response.code
    when '200'
      JSON.parse(response.body)
    else
      ERROR_MESSAGES[response.code] || 'Unknown error'
    end
  end

  def format_current_weather(city, data)
    WeatherFormatter.new(city).format_current(data)
  end

  def format_forecast(city, days, data)
    WeatherFormatter.new(city).format_forecast(days, data['forecasts'])
  end
end

class WeatherFormatter
  def initialize(city)
    @city = city
  end

  def format_current(data)
    [
      "Weather in #{@city}:",
      "Temperature: #{data['temperature']}\u00b0C,",
      "Description: #{data['description']},",
      "Humidity: #{data['humidity']}%,",
      "Wind: #{data['wind_speed']}km/h"
    ].join(' ')
  end

  def format_forecast(days, forecasts)
    header = "#{days}-day forecast for #{@city}:"
    daily_forecasts = forecasts.map do |forecast|
      format_daily_forecast(forecast)
    end

    ([header] + daily_forecasts).join("\n")
  end

  private

  def format_daily_forecast(forecast)
    "#{forecast['date']}: #{forecast['temperature']}\u00b0C, #{forecast['description']}"
  end
end
