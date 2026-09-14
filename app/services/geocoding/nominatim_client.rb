module Geocoding
  class NominatimClient
    BASE_URL = "https://nominatim.openstreetmap.org"
    
    def self.search(query, limit: 5)
      response = connection.get("/search", {
        q: query,
        format: "jsonv2",
        addressdetails: 1,
        limit: limit
      }).body

      normalize(response)
    end

    def self.connection
      Faraday.new(url: BASE_URL) do |f|
        f.headers["User-Agent"] = "Forecastly"
        f.response :json
        f.options.timeout = 5
        f.options.open_timeout = 3
      end
    end

    def self.normalize(results)
      results.map do |result|
        {
          "label" => result["display_name"],
          "zip_code" => result.dig("address", "postcode"),
          "latitude" => result["lat"],
          "longitude" => result["lon"],
          "place_id" => result["place_id"]
        }
      end
    end
  end
end