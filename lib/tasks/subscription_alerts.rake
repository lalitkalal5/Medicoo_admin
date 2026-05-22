namespace :subscriptions do
  desc "Email alerts for customers expiring within 7 days"
  task notify_expiring: :environment do
    next unless ENV["ADMIN_ALERT_EMAIL"].present? && ENV["SMTP_ADDRESS"].present?

    Customer.expiring_soon.find_each do |customer|
      CustomerAlertMailer.with(customer:).expiring_soon.deliver_now
    end
  end
end
