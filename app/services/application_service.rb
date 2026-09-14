class ApplicationService
  # Avoid to declare it in every Service object
  def self.call(...)
    new(...).call
  end
end