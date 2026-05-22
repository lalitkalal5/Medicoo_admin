Rails.application.config.filter_parameters += [
  :password,
  :api_key,
  :groq_api_key,
  :license_key,
  :device_identifier
]
