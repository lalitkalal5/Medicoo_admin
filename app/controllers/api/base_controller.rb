module Api
  class BaseController < ActionController::API
    before_action :ensure_json_request

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from LicenseError, with: :render_license_error

    private

    def ensure_json_request
      request.format = :json
    end

    def render_not_found(error)
      render json: { error: error.message }, status: :not_found
    end

    def render_license_error(error)
      render json: { error: error.message }, status: error.status
    end
  end
end
