source "https://rubygems.org"

ruby "3.4.5"

gem "bcrypt", "~> 3.1"
gem "bootsnap", require: false
gem "puma", ">= 5.0"
gem "rack-attack"
gem "rack-cors"
gem "rails", "~> 7.1.5"
gem "sprockets-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "dotenv-rails"
  gem "rubocop-rails-omakase", require: false
  gem "sqlite3", "~> 2.1"
end

group :production do
  gem "pg", "~> 1.1"
end
