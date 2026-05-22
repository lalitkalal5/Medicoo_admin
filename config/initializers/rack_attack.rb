class Rack::Attack
  throttle("api/ip", limit: ENV.fetch("API_RATE_LIMIT_PER_MINUTE", 60).to_i, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/") || ["/assign-key", "/refresh-key", "/validate"].include?(req.path)
  end

  throttle("api/license", limit: ENV.fetch("LICENSE_RATE_LIMIT_PER_MINUTE", 30).to_i, period: 1.minute) do |req|
    if req.post? || req.get?
      req.params["license_key"].presence
    end
  rescue StandardError
    nil
  end

  self.throttled_responder = lambda do |_request|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded" }.to_json]]
  end
end
