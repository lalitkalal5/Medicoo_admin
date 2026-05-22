class GroqKeyAssigner
  def initialize(customer:, force_new_key: false, preferred_key: nil)
    @customer = customer
    @force_new_key = force_new_key
    @preferred_key = preferred_key
  end

  def assign!
    raise LicenseError.new("Customer subscription is not active") unless customer.active_subscription?

    ApplicationRecord.transaction do
      release_current_key! if force_new_key

      return customer.groq_key if customer.groq_key.present? && !force_new_key

      key = preferred_key || GroqKey.available.order(:created_at).first
      raise LicenseError.new("No Groq keys available for assignment", :service_unavailable) if key.nil?

      key.release! if key.is_assigned? && key.assigned_customer.present?
      key.assign_to!(customer)
      key
    end
  end

  private

  attr_reader :customer, :force_new_key, :preferred_key

  def release_current_key!
    customer.groq_key&.release!
  end
end
