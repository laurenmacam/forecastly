module Weather
  class ForecastWeather < ApplicationService
    def initialize(zip_code:, latitude:, longitude:, place_id:, label:)
      @zip_code = zip_code
      @latitude = latitude
      @longitude = longitude
      @place_id = place_id
      @label = label
    end

    def call
      from_cache = true

      data = Rails.cache.fetch(cache_key, expires_in: 30.minutes, skip_nil: true) do
        from_cache = false
        Weather::GoogleClient.current_conditions(latitude: @latitude, longitude: @longitude)
      end

      ServiceResult.success({
        zip_code: @zip_code,
        place_id: @place_id,
        label: @label,
        forecast: data,
        from_cache: from_cache
      })
    rescue Faraday::Error => e
      Rails.logger.error("Weather API failed: #{e.message}")
      ServiceResult.failure("Weather service unavailable")
    end

    private

    def cache_key
      identifier = @zip_code.presence || @place_id.presence
      "forecast_#{identifier}"
    end
  end
end
