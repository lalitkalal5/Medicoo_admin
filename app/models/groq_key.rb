class GroqKey < ApplicationRecord
  encrypts :api_key

  belongs_to :assigned_customer, class_name: "Customer", optional: true, foreign_key: :assigned_to_customer_id
  has_many :activation_logs, dependent: :nullify

  validates :api_key, presence: true

  scope :available, -> { where(is_assigned: false, assigned_to_customer_id: nil) }
  scope :assigned, -> { where(is_assigned: true) }

  def masked_api_key
    return "" if api_key.blank?

    "#{api_key.first(6)}...#{api_key.last(4)}"
  end

  def assign_to!(customer)
    transaction do
      update!(
        is_assigned: true,
        assigned_customer: customer,
        assigned_at: Time.current
      )
      customer.update!(groq_key: self)
    end
  end

  def release!
    transaction do
      assigned_customer&.update!(groq_key: nil)
      update!(is_assigned: false, assigned_customer: nil, assigned_at: nil)
    end
  end
end
