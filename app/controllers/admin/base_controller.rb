module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    helper_method :current_admin_username

    private

    def authenticate_admin!
      return if session[:admin_authenticated]

      redirect_to "/login", alert: "Please sign in to access the dashboard."
    end

    def current_admin_username
      ENV.fetch("ADMIN_USERNAME", "admin")
    end
  end
end
