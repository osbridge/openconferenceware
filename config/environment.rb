# Display all the files required or loaded if the VERBOSE_LOADING environmental
# variable is defined, e.g., "VERBOSE_LOAD=1 script/server"
if ENV['VERBOSE_LOAD']
  alias :require_without_announcer :require
  def require_with_announcer(*args)
    puts "require: #{args.inspect}"
    require_without_announcer(*args)
  end
  alias :require :require_with_announcer

  alias :load_without_announcer :load
  def load_with_announcer(*args)
    puts "load: #{args.inspect}"
    load_without_announcer(*args)
  end
  alias :load :load_with_announcer
end

# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# NOTE: When upgrading, change Gemfile too because it must match
RAILS_GEM_VERSION = '~> 2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # For more gem dependencies see:
  # * Gemfile
  # * config/initializers/libraries.rb

  # Activate gems in vendor/gems
  config.gem 'comma'

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.autoload_paths += %W[
    #{RAILS_ROOT}/app/observers
    #{RAILS_ROOT}/app/mixins
  ]

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = [:cache_watcher, :shared_fragment_watcher] unless defined?(Rake::Task) && ARGV.find{|t| /^db:(create|drop)/}
  # TODO Remove the above "unless" after migrating to Rails 2.3 or above. It's needed by older versions to avoid a dependency loop where creating the database requires loading the observers which load the models which have plugins that try to talk to the database.

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  #---[ Custom libraries ]------------------------------------------------

  # Load custom libraries before "config/initializers" run.
  $LOAD_PATH.unshift("#{RAILS_ROOT}/lib")

  # Read secrets
  require 'secrets_reader'
  SECRETS = SecretsReader.read

  # Read settings
  require 'settings_reader'
  SETTINGS = SettingsReader.read(
    File.join(RAILS_ROOT, 'config', 'settings.yml'), {
      'public_url' => 'http://change_your/settings.yml/',
      'mailer_host' => 'change-your-mailer-host.local',
      'organization' => 'Default Organization Name',
      'Organization_slug' => 'defaultslug',
      'tagline' => 'Default Tagline',
      'breadcrumbs' => [],
      'timezone' => 'Pacific Time (US & Canada)',
      'have_anonymous_proposals' => true,
      'have_proposal_excerpts' => false,
      'have_event_tracks' => false,
      'have_event_session_types' => false,
      'have_events_picker' => true,
      'have_multiple_presenters' => false,
      'have_user_pictures' => false,
      'have_user_profiles' => false,
      'have_event_rooms' => false,
      'have_proposal_start_times' => false,
      'have_proposal_statuses' => false,
      'have_event_proposal_comments_after_deadline' => true,
    }
  )

  # Set timezone
  config.time_zone = SETTINGS.timezone

  # Set cookie session
  config.action_controller.session = {
    :session_key => SECRETS.session_name || 'openproposals',
    :secret => SECRETS.session_secret,
  }

  # Setup default host for use in mailers
  config.action_mailer.default_url_options = { :host => SETTINGS.mailer_host }

  # Setup cache
  require 'rails_cache_configurator'
  RailsCacheConfigurator.apply(config)
end
