module ForecastsHelper
  TEMPERATURE_UNITS = { "CELSIUS" => "°C", "FAHRENHEIT" => "°F" }
  SPEED_UNITS       = { "KILOMETERS_PER_HOUR" => "km/h", "MILES_PER_HOUR" => "mph" }

  def forecast_data(forecast)
    # with_indifferent_access converts nested hashes, so `dig(:a, :b)` works all the way down
    forecast.respond_to?(:with_indifferent_access) ? forecast.with_indifferent_access : {}
  end

  def temperature_text(temperature)
    degrees = temperature && temperature[:degrees]
    return "—" if degrees.blank?

    # Given {degrees: 26.7, unit: "CELSIUS"} returns "27°C"
    "#{number_with_precision(degrees, precision: 0)}#{TEMPERATURE_UNITS.fetch(temperature[:unit], "°")}"
  end

  def speed_text(speed)
    value = speed && speed[:value]
    return "—" if value.blank?

    # Given {value: 13, unit: "KILOMETERS_PER_HOUR"} returns "13 km/h"
    "#{value} #{SPEED_UNITS.fetch(speed[:unit], "")}".strip
  end

  def percent_text(value)
    value.blank? ? "—" : "#{value}%"
  end
end
