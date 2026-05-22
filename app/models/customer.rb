class Customer < ApplicationRecord
  belongs_to :groq_key, optional: true
  has_many :activation_logs, dependent: :destroy
  has_many :owned_groq_keys, class_name: "GroqKey", foreign_key: :assigned_customer_id, dependent: :nullify

  enum :plan_type, { monthly: "monthly", yearly: "yearly", custom: "custom" }, validate: true
  enum :status, { active: "active", expired: "expired", suspended: "suspended" }, validate: true

  validates :license_key, presence: true, uniqueness: true
  validates :full_name, :email, :phone_number, :subscription_start_date, :subscription_expiry_date, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :expiry_after_start

  scope :search, lambda { |term|
    value = "%#{term.to_s.strip}%"
    where(
      "full_name ILIKE :value OR business_name ILIKE :value OR phone_number ILIKE :value OR license_key ILIKE :value",
      value:
    )
  }
  scope :expiring_soon, -> { where(status: "active", subscription_expiry_date: Date.current..(Date.current + 7.days)) }
  scope :expired_or_past_due, lambda {
    where(status: "expired").or(where("subscription_expiry_date < ?", Date.current))
  }

  before_validation :normalize_license_key
  before_save :refresh_status_if_expired

  def active_subscription?
    active? && subscription_expiry_date.present? && subscription_expiry_date >= Date.current
  end

  def days_until_expiry
    return 0 if subscription_expiry_date.blank?

    [(subscription_expiry_date - Date.current).to_i, 0].max
  end

  def device_matches?(incoming_identifier)
    return false if incoming_identifier.blank?
    return true if device_identifier.blank?

    ActiveSupport::SecurityUtils.secure_compare(device_identifier, incoming_identifier)
  end

  private

  def normalize_license_key
    self.license_key = license_key.to_s.upcase
  end

  def expiry_after_start
    return if subscription_start_date.blank? || subscription_expiry_date.blank?
    return if subscription_expiry_date >= subscription_start_date

    errors.add(:subscription_expiry_date, "must be on or after the start date")
  end

  def refresh_status_if_expired
    self.status = "expired" if subscription_expiry_date.present? && subscription_expiry_date < Date.current && !suspended?
  end
end
