class ApplicationController < ActionController::Base
  # JSON endpoint doesn't carry a session. The HTML form keeps full CSRF protection.

  protect_from_forgery with: :exception, unless: -> { request.format.json? }
end
