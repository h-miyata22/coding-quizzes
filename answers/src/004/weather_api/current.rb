module WeatherAPI
  class Current < Base
    def initialize
      super('/current')
    end

    private

    def validate_params(params)
      raise ArgumentError, 'City is required' if params[:city].nil? || params[:city].empty?
    end

    def display_result(data, params)
      city = params[:city]
      
      "Weather in #{city}: " \
        "Temperature: #{data['temperature']}\u00b0C, " \
        "Description: #{data['description']}, " \
        "Humidity: #{data['humidity']}%, " \
        "Wind: #{data['wind_speed']}km/h"
    end
  end
end