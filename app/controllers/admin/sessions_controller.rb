module Admin
  class SessionsController < ApplicationController
    layout "admin_auth"

    def new; end

    def create
      if valid_admin_credentials?
        session[:admin_authenticated] = true
        redirect_to admin_dashboard_path, notice: "Signed in successfully."
      else
        flash.now[:alert] = "Invalid username or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session
      redirect_to "/login", notice: "Signed out."
    end

    private

    def valid_admin_credentials?
      username = params[:username].to_s
      password = params[:password].to_s
      expected_username = ENV.fetch("ADMIN_USERNAME", "admin")
      expected_password = ENV.fetch("ADMIN_PASSWORD", "change-me-now")

      secure_compare(username, expected_username) && secure_compare(password, expected_password)
    end

    def secure_compare(left, right)
      return false if left.blank? || right.blank? || left.bytesize != right.bytesize

      ActiveSupport::SecurityUtils.secure_compare(left, right)
    end
  end
end
