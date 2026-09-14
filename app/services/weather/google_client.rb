module Weather
  class GoogleClient
    BASE_URL = "https://weather.googleapis.com"

    def self.current_conditions(latitude:, longitude:)
      response = connection.get("/v1/currentConditions:lookup", {
        key: ENV.fetch("GOOGLE_API_KEY"),
        "location.latitude": latitude,
        "location.longitude": longitude
      })

      response.body
    end

    def self.connection
      Faraday.new(url: BASE_URL) do |f|
        f.response :json
        f.options.timeout = 5
        f.options.open_timeout = 3
      end
    end
  end
end
