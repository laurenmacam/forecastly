require "rails_helper"

RSpec.describe Geocoding::GoogleClient do
  describe ".search" do
    let(:response_body) do
      {
        "results" => [
          {
            "formattedAddress" => "Beverly Hills, CA 90210, USA",
            "placeId" => "ChIJ0",
            "location" => { "latitude" => 34.09, "longitude" => -118.40 },
            "addressComponents" => [
              { "longText" => "California", "types" => [ "administrative_area_level_1" ] },
              { "longText" => "90210", "types" => [ "postal_code" ] }
            ]
          }
        ]
      }
    end

    def stub_geocode(body)
      stub_request(:get, %r{\Ahttps://geocode\.googleapis\.com/v4/geocode/address/})
        .to_return(
          status: 200,
          body: body.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "normalizes the response with hashes" do
      stub_geocode(response_body)

      expect(described_class.search("beverly hills").first).to eq(
        "label" => "Beverly Hills, CA 90210, USA",
        "zip_code" => "90210",
        "latitude" => 34.09,
        "longitude" => -118.40,
        "place_id" => "ChIJ0"
      )
    end

    it "returns an empty array when the API returns no results" do
      stub_geocode("results" => [])

      expect(described_class.search("nowhere")).to eq([])
    end
  end
end
