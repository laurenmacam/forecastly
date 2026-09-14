require "rails_helper"

RSpec.describe Geocoding::AddressSuggestions do
  describe ".call" do
    context "when query is too short" do
      it "returns empty array without hitting the API" do
        expect(Geocoding::GoogleClient).not_to receive(:search)

        result = described_class.call("ab")

        expect(result.success?).to be true
        expect(result.value).to eq([])
      end
    end

    context "with a valid query" do
      before do
        allow(Geocoding::GoogleClient).to receive(:search).and_return([
          {
            "label" => "Beverly Hills, CA 90210, USA",
            "zip_code" => "90210",
            "latitude" => 34.09,
            "longitude" => -118.40,
            "place_id" => "ChIJ0"
          },
          {
            "label" => "Somewhere Unnamed",
            "zip_code" => nil,
            "latitude" => 35.0,
            "longitude" => -119.0,
            "place_id" => nil
          }
        ])
      end

      it "carries label, coordinates and place id into the suggestion" do
        suggestion = described_class.call("beverly").value.first

        expect(suggestion.label).to eq("Beverly Hills, CA 90210, USA")
        expect(suggestion.latitude).to eq(34.09)
        expect(suggestion.longitude).to eq(-118.40)
        expect(suggestion.place_id).to eq("ChIJ0")
      end
    end

    context "when the API fails" do
      before do
        allow(Geocoding::GoogleClient).to receive(:search).and_raise(Faraday::TimeoutError)
      end

      it "returns empty array instead of raising" do
        result = described_class.call("beverly hills")

        expect(result.success?).to be true
        expect(result.value).to eq([])
      end
    end
  end
end
