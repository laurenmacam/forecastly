module Geocoding
  class AddressSuggestions < ApplicationService
    Suggestion = Data.define(:label, :zip_code, :latitude, :longitude, :place_id)

    def initialize(query)
      @query = query.to_s.strip
    end

    def call
      return ServiceResult.success([]) if @query.length < 3

      results = Geocoding::GoogleClient.search(@query)

      suggestions = results.filter_map do |result|
        next unless result["zip_code"].present? || result["place_id"].present?

        Suggestion.new(
          label: result["label"],
          zip_code: result["zip_code"],
          latitude: result["latitude"],
          longitude: result["longitude"],
          place_id: result["place_id"]
        )
      end

      ServiceResult.success(suggestions)
    rescue Faraday::Error => e
      Rails.logger.error("Geocoding provider failed: #{e.message}")
      ServiceResult.success([])
    end
  end
end