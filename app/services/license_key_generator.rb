class LicenseKeyGenerator
  SEGMENT_LENGTH = 4
  SEGMENT_COUNT = 4
  ALPHABET = ("A".."Z").to_a.concat(("0".."9").to_a).freeze

  def self.generate
    loop do
      key = Array.new(SEGMENT_COUNT) { Array.new(SEGMENT_LENGTH) { ALPHABET.sample }.join }.join("-")
      return key unless Customer.exists?(license_key: key)
    end
  end
end
