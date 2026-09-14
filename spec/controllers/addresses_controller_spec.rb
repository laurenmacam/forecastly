require "rails_helper"

RSpec.describe AddressesController, type: :controller do
  render_views

  describe "GET #suggestions" do
    let(:suggestion) do
      Geocoding::AddressSuggestions::Suggestion.new(
        label: "Beverly Hills, CA 90210, USA",
        zip_code: "90210",
        latitude: 34.09,
        longitude: -118.40,
        place_id: "ChIJ0"
      )
    end

    before do
      allow(Geocoding::AddressSuggestions).to receive(:call)
        .and_return(ServiceResult.success([suggestion]))
    end

    it "returns suggestions as JSON" do
      get :suggestions, params: { query: "beverly" }, format: :json

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.first["zip_code"]).to eq("90210")
      expect(body.first["place_id"]).to eq("ChIJ0")
    end

    it "renders the suggestions partial as HTML" do
      get :suggestions, params: { query: "beverly" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Beverly Hills, CA 90210, USA")
    end
  end
end
