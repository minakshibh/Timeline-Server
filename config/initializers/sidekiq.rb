if Rails.env.production?
  redis_url = 'redis://dev.rodeo.clicklabs.in:6379/12'
else
  redis_url = 'redis://localhost:6379/12'
end

Sidekiq.hook_rails!
Sidekiq.remove_delay!

Sidekiq.configure_server do |config|
  config.redis = { :url => redis_url, :namespace => 'twistilled'}
end

Sidekiq.configure_client do |config|
  config.redis = { :url => redis_url, :namespace => 'twistilled' }
end

if Rails.env.development?
  Sidekiq::Logging.logger.level = Logger::INFO
else
  Sidekiq::Logging.logger.level = Logger::WARN
end