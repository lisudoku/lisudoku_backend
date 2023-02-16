require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('SIDEKIQ_REDIS_URL') { 'redis://localhost:6379/1' },
  }

  config.on(:startup) do
    schedule_file = 'config/schedule.yml'

    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('SIDEKIQ_REDIS_URL') { 'redis://localhost:6379/1' },
  }
end

if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic, 'Protected Area' do |username, password|
    Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_username!)) &
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_password!))
  end
end
