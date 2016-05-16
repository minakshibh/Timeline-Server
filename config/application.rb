require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# Load MySQL Adapter directly to avoid ActiveUUID Errors
require "active_record/connection_adapters/mysql2_adapter"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TimelineServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Delayed Job
    config.active_job.queue_adapter = :delayed_job

    # Allow loading modules from /lib/ directory
    # config.autoload_paths << Rails.root.join('lib')
    # config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib)

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    Backburner.configure do |config|
      config.beanstalk_url       = ["beanstalk://127.0.0.1", "beanstalk://54.173.66.114"]
      config.tube_namespace      = "Timeline.app.production"
      config.namespace_separator = "."
      config.on_error            = lambda { |e| puts e }
      config.max_job_retries     = 3 # default 0 retries
      config.retry_delay         = 2 # default 5 seconds
      config.retry_delay_proc    = lambda { |min_retry_delay, num_retries| min_retry_delay + (num_retries ** 3) }
      config.default_priority    = 65536
      config.respond_timeout     = 120
      config.default_worker      = Backburner::Workers::Forking
      config.logger              = Logger.new(STDOUT)
      config.primary_queue       = "backburner-jobs"
      config.priority_labels     = { :custom => 50, :useless => 1000 }
      config.reserve_timeout     = nil
    end


  end
end
