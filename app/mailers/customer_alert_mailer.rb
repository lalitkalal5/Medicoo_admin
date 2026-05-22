class CustomerAlertMailer < ApplicationMailer
  def new_activation
    @customer = params[:customer]
    @ip_address = params[:ip_address]

    mail(
      to: ENV.fetch("ADMIN_ALERT_EMAIL"),
      subject: "New activation for #{@customer.full_name}"
    )
  end

  def expiring_soon
    @customer = params[:customer]

    mail(
      to: ENV.fetch("ADMIN_ALERT_EMAIL"),
      subject: "Subscription expiring soon for #{@customer.full_name}"
    )
  end
end
