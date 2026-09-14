class AddressesController < ApplicationController
  def suggestions
    result = Geocoding::AddressSuggestions.call(params[:query])

    respond_to do |format|
      format.html { render partial: "addresses/suggestions", locals: { suggestions: result.value } }
      format.json { render json: result.value }
    end
  end
end
