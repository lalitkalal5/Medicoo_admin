class LicenseAccessValidator
  def initialize(customer:, device_identifier:)
    @customer = customer
    @device_identifier = device_identifier
  end

  def validate!
    raise LicenseError.new("License is suspended", :forbidden) if customer.suspended?
    raise LicenseError.new("License has expired", :forbidden) unless customer.active_subscription?

    if customer.device_identifier.blank?
      customer.update!(device_identifier: device_identifier)
      return true
    end

    raise LicenseError.new("Invalid device for this license", :forbidden) unless customer.device_matches?(device_identifier)

    true
  end

  private

  attr_reader :customer, :device_identifier
end
