require "rails_helper"

RSpec.describe ForecastsController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:forecast_data) { { "temperature" => { "degrees" => 25 } } }

      before do
        allow(Weather::ForecastWeather).to receive(:call).and_return(
          ServiceResult.success({ zip_code: "90210", from_cache: false, forecast: forecast_data })
        )
      end

      it "returns success as JSON" do
        post :create, params: { zip_code: "90210", latitude: "34.09", longitude: "-118.40" }, format: :json

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["zip_code"]).to eq("90210")
        expect(body["from_cache"]).to be false
      end
    end

    context "with missing zip code" do
      it "returns error as JSON" do
        post :create, params: { zip_code: "" }, format: :json

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body["error"]).to be_present
      end
    end
  end
end