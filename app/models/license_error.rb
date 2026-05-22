class LicenseError < StandardError
  attr_reader :status

  def initialize(message, status = :unprocessable_entity)
    @status = status
    super(message)
  end
end
