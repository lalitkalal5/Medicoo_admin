require_relative "boot"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "active_model"
require "active_model/validations/helper_methods"
require "active_model/validations"
validation_dir = "#{Gem.loaded_specs.fetch("activemodel").full_gem_path}/lib/active_model/validations"
Dir.children(validation_dir).sort.each do |entry|
  next unless entry.end_with?(".rb")
  next if entry == "helper_methods.rb"

  require "#{validation_dir}/#{entry}"
end
require "active_record"

Bundler.require(*Rails.groups)

ENV.delete("DATABASE_URL") unless ENV.fetch("RAILS_ENV", "development") == "production"

module MedicooAdmin
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = false

    config.time_zone = ENV.fetch("APP_TIME_ZONE", "Asia/Kolkata")
    config.active_record.default_timezone = :utc

    config.middleware.use Rack::Cors do
      allow do
        origins ENV.fetch("ALLOWED_ORIGINS", "*").split(",").map(&:strip)
        resource "/api/*", headers: :any, methods: %i[get post options]
        resource "/assign-key", headers: :any, methods: [:post]
        resource "/refresh-key", headers: :any, methods: [:post]
        resource "/validate", headers: :any, methods: [:get]
      end
    end

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: "_medicoo_admin_session"
    config.middleware.use Rack::Attack

    config.generators do |g|
      g.helper false
      g.assets false
      g.stylesheets false
      g.javascripts false
      g.test_framework nil
    end
  end
end
