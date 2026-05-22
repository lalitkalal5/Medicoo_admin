class LicensePayloadEncryptor
  def self.encrypt(value)
    return nil if value.blank?

    crypt.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    crypt.decrypt_and_verify(value)
  end

  def self.crypt
    secret = ENV.fetch("LICENSE_RESPONSE_SECRET")
    key = ActiveSupport::KeyGenerator.new(secret).generate_key("groq-license-payload", 32)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
