class ActivationLog < ApplicationRecord
  belongs_to :customer
  belongs_to :groq_key, optional: true

  validates :device_identifier, :activated_at, :action, presence: true

  scope :recent, -> { order(activated_at: :desc, created_at: :desc) }
end
