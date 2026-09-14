require "rails_helper"

RSpec.describe Weather::ForecastWeather do
  let(:weather_data) { { "temperature" => { "degrees" => 25, "unit" => "CELSIUS" } } }

  let(:place) do
    {
      zip_code: "90210",
      latitude: "34.09",
      longitude: "-118.40",
      place_id: "ChIJ0",
      label: "Beverly Hills, CA 90210, USA"
    }
  end

  before do
    Rails.cache.clear
    allow(Weather::GoogleClient).to receive(:current_conditions).and_return(weather_data)
  end

  describe ".call" do
    it "returns the forecast alongside the place typed" do
      result = described_class.call(**place)

      expect(result.success?).to be true
      expect(result.value[:zip_code]).to eq("90210")
      expect(result.value[:place_id]).to eq("ChIJ0")
      expect(result.value[:label]).to eq("Beverly Hills, CA 90210, USA")
      expect(result.value[:forecast]).to eq(weather_data)
    end

    it "returns from_cache false on first call" do
      expect(described_class.call(**place).value[:from_cache]).to be false
    end

    it "returns from_cache true on subsequent calls with same zip" do
      described_class.call(**place)

      expect(described_class.call(**place).value[:from_cache]).to be true
    end

    it "does not hit the API on cached requests" do
      described_class.call(**place)
      described_class.call(**place)

      expect(Weather::GoogleClient).to have_received(:current_conditions).once
    end

    it "caches by place id when there is no zip code" do
      without_zip = place.merge(zip_code: nil)

      described_class.call(**without_zip)
      result = described_class.call(**without_zip)

      expect(result.value[:from_cache]).to be true
      expect(Weather::GoogleClient).to have_received(:current_conditions).once
    end

    context "when the API fails" do
      before do
        allow(Weather::GoogleClient).to receive(:current_conditions).and_raise(Faraday::TimeoutError)
      end

      it "returns a failure result" do
        result = described_class.call(**place)

        expect(result.success?).to be false
        expect(result.error).to eq("Weather service unavailable")
      end
    end
  end
end
