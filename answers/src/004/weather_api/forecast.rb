module WeatherAPI
  class Forecast < Base
    def initialize
      super('/forecast')
    end

    private

    def validate_params(params)
      raise ArgumentError, 'City is required' if params[:city].nil? || params[:city].empty?
      raise ArgumentError, 'Days must be between 1 and 7' if params[:days].nil? || params[:days] < 1 || params[:days] > 7
    end

    def display_result(data, params)
      city = params[:city]
      days = params[:days]

      result = "#{days}-day forecast for #{city}:\n"
      for i in 0..data['forecasts'].length - 1
        date = data['forecasts'][i]['date']
        temp = data['forecasts'][i]['temperature']
        desc = data['forecasts'][i]['description']

        result += "#{date}: #{temp}\u00b0C, #{desc}\n"
      end

      result
    end
  end
end