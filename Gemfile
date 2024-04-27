source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.5'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.4'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'kredis'

# For redis cache store
gem 'hiredis'
gem 'connection_pool'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  gem 'debug'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

# TODO: check out jbuilder, may be better
gem 'active_model_serializers', '~> 0.10.0'

gem 'devise'
gem 'devise-jwt'
gem 'cancancan'

gem 'honeybadger', '~> 5.0'

# Background jobs
gem 'sidekiq', '~> 7.0.2'
gem 'sidekiq-cron', '~> 1.9.1'

gem 'newrelic_rpm'
gem 'prometheus-client'
