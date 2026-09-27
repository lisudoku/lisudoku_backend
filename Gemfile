source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.11'

gem 'rails', '~> 7.2.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 8.0.2'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'kredis', '~> 1.8.0'

# For redis cache store
gem 'hiredis'
gem 'connection_pool'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.26', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  gem 'debug', '~> 1.9'
  gem 'rspec-rails', '~> 8.0.4'
  gem 'factory_bot_rails', '~> 6.5.1'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

# TODO: check out jbuilder, may be better
gem 'active_model_serializers', '~> 0.10.0'

gem 'devise', '~> 5.0.4'
gem 'devise-jwt', '~> 0.13.0'

gem 'cancancan'

gem 'honeybadger', '~> 6.9.2'

# Background jobs
gem 'sidekiq', '~> 8.1.7'
gem 'sidekiq-cron', '~> 2.4.0'

gem 'newrelic_rpm', '~> 10.8'
gem 'prometheus-client'

# Remove after upgrading to Rails 8.1+
gem "mutex_m"
gem "observer"
gem "json", "~> 2.7"
