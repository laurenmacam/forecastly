require "rails_helper"

RSpec.describe Geocoding::NominatimClient do
  describe ".search" do
    def stub_nominatim(query, body)
      stub_request(:get, "https://nominatim.openstreetmap.org/search")
        .with(query: hash_including(q: query))
        .to_return(
          status: 200,
          body: body.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "normalizes the response with hashes" do
      stub_nominatim("90210", [
        {
          "display_name" => "Beverly Hills, CA 90210, USA",
          "place_id" => 123456,
          "address" => { "postcode" => "90210" },
          "lat" => "34.09",
          "lon" => "-118.40"
        }
      ])

      expect(described_class.search("90210").first).to eq(
        "label" => "Beverly Hills, CA 90210, USA",
        "zip_code" => "90210",
        "latitude" => "34.09",
        "longitude" => "-118.40",
        "place_id" => 123456
      )
    end
  end
end
