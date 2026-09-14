ServiceResult = Data.define(:success?, :value, :error) do
  def self.success(value)
    new(success?: true, value: value, error: nil)
  end

  def self.failure(error)
    new(success?: false, value: nil, error: error)
  end
end