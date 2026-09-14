class ForecastsController < ApplicationController
  def new
  end

  def create
    if params[:zip_code].blank? && params[:place_id].blank?
      @result = ServiceResult.failure("Please select an address from the suggestions")
    else
      @result = Weather::ForecastWeather.call(
        zip_code: params[:zip_code],
        latitude: params[:latitude],
        longitude: params[:longitude],
        place_id: params[:place_id],
        label: params[:label]
      )
    end

    respond_to do |format|
      format.html { render :new }
      format.json { render json: @result.success? ? @result.value : { error: @result.error }, status: @result.success? ? :ok : :unprocessable_content }
    end
  end
end
