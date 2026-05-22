module Api
  class LicensesController < BaseController
    def activate
      customer = Customer.find_by!(license_key: normalized_license_key)
      LicenseAccessValidator.new(customer:, device_identifier: device_identifier).validate!
      key = GroqKeyAssigner.new(customer:).assign!

      ActivationLog.create!(
        customer:,
        groq_key: key,
        device_identifier: device_identifier,
        ip_address: request_ip,
        activated_at: Time.current,
        action: "first_activation"
      )

      CustomerAlertMailer.with(customer:, action: "new_activation", ip_address: request_ip).new_activation.deliver_later if notify_mailer_ready?

      render json: license_payload(customer, key)
    end

    def refresh_key
      customer = Customer.find_by!(license_key: normalized_license_key)
      LicenseAccessValidator.new(customer:, device_identifier: device_identifier).validate!
      key = GroqKeyAssigner.new(customer:, force_new_key: true).assign!

      ActivationLog.create!(
        customer:,
        groq_key: key,
        device_identifier: device_identifier,
        ip_address: request_ip,
        activated_at: Time.current,
        action: "key_refresh"
      )

      render json: license_payload(customer, key).merge(message: "Fresh Groq key assigned")
    end

    def validate_license
      customer = Customer.find_by(license_key: normalized_license_key)

      if customer.nil?
        render json: { is_valid: false, status: "missing", days_until_expiry: 0 }, status: :not_found
        return
      end

      valid = customer.device_matches?(device_identifier) && customer.active_subscription?

      ActivationLog.create!(
        customer:,
        groq_key: customer.groq_key,
        device_identifier: device_identifier,
        ip_address: request_ip,
        activated_at: Time.current,
        action: "login_check"
      )

      render json: {
        is_valid: valid,
        status: customer.status,
        days_until_expiry: customer.days_until_expiry,
        expires_on: customer.subscription_expiry_date
      }
    end

    def register_device
      customer = Customer.find_by!(license_key: normalized_license_key)

      if customer.device_identifier.present? && !customer.device_matches?(device_identifier)
        raise LicenseError.new("This license is already bound to another device", :unprocessable_entity)
      end

      customer.update!(device_identifier: device_identifier)

      ActivationLog.create!(
        customer:,
        groq_key: customer.groq_key,
        device_identifier: device_identifier,
        ip_address: request_ip,
        activated_at: Time.current,
        action: "device_registration"
      )

      render json: { message: "Device registered successfully", device_identifier: customer.device_identifier }
    end

    private

    def normalized_license_key
      params.require(:license_key).to_s.strip.upcase
    end

    def device_identifier
      params.require(:device_identifier).to_s.strip
    end

    def request_ip
      params[:ip_address].presence || request.remote_ip
    end

    def license_payload(customer, key)
      {
        groq_api_key: key.api_key,
        encrypted_groq_api_key: LicensePayloadEncryptor.encrypt(key.api_key),
        expiry_date: customer.subscription_expiry_date,
        customer_name: customer.full_name,
        status: customer.status,
        license_key: customer.license_key
      }
    end

    def notify_mailer_ready?
      ENV["ADMIN_ALERT_EMAIL"].present? && ENV["SMTP_ADDRESS"].present?
    end
  end
end
