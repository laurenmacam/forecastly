module Geocoding
  class GoogleClient
    BASE_URL = "https://geocode.googleapis.com"

    def self.search(query)
      response = connection.get("/v4/geocode/address/#{encode(query)}", {
        key: ENV.fetch("GOOGLE_API_KEY")
      }).body

      normalize(response)
    end

    def self.connection
      Faraday.new(url: BASE_URL) do |f|
        f.response :json
        f.options.timeout = 5
        f.options.open_timeout = 3
      end
    end

    def self.encode(query)
      ERB::Util.url_encode(query)
    end

    def self.normalize(response)
      (response["results"] || []).map do |result|
        {
          "label" => result["formattedAddress"],
          "zip_code" => extract_postal_code(result),
          "latitude" => result.dig("location", "latitude"),
          "longitude" => result.dig("location", "longitude"),
          "place_id" => result["placeId"]
        }
      end
    end

    def self.extract_postal_code(result)
      postal = (result["addressComponents"] || []).find do |component|
        (component["types"] || []).include?("postal_code")
      end

      postal&.dig("longText")
    end
  end
end