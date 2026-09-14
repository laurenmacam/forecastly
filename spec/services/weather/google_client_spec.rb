require "rails_helper"

RSpec.describe Weather::GoogleClient do
  describe ".current_conditions" do
    let(:response_body) do
      { "temperature" => { "degrees" => 25, "unit" => "CELSIUS" } }
    end

    before do
      stub_request(:get, "https://weather.googleapis.com/v1/currentConditions:lookup")
        .with(query: hash_including("location.latitude": "34.09", "location.longitude": "-118.40"))
        .to_return(status: 200, body: response_body.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "returns parsed weather data" do
      result = described_class.current_conditions(latitude: "34.09", longitude: "-118.40")

      expect(result.dig("temperature", "degrees")).to eq(25)
    end
  end
end
