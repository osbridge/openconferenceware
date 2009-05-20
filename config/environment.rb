# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '~> 2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Gems that are selectively loaded
  config.gem "sqlite3-ruby", :lib => false
  config.gem "ruby-openid", :lib => false # Selectively loaded by open_id_authentication plugin
  config.gem "facets", :lib => false # Selectively loaded by config/initializers/dependencies.rb
  config.gem "right_aws", :lib => false # we aren't actually using AWS, but paperclip can, so it requires it.

  # Gems only used for development and test
  if %w[development test].include?(RAILS_ENV) then
    config.gem "rspec", :lib => false, :version => ">=1.2.2"
    config.gem "rspec-rails", :lib => false, :version => ">=1.2.2"
    config.gem "webrat", :lib => false, :version => ">=0.4.3"
    config.gem "cucumber", :lib => false, :version => ">=0.2.2"
  end

  # Gems to load into the environment
  config.gem "newrelic_rpm" if ENV['NEWRELIC'] # Only include NewRelic profiling if requested, e.g.,: NEWRELIC=1 ./script/server
  config.gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"
  config.gem "thoughtbot-paperclip", :source => "http://gems.github.com", :lib => 'paperclip'
  config.gem "rubyist-aasm", :source => "http://gems.github.com", :lib => 'aasm'
  config.gem "gchartrb", :lib => "google_chart"
  config.gem "vpim", :lib => 'vpim/icalendar'
  config.gem "RedCloth"
  config.gem 'color'

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
  config.load_paths += %W[
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
  config.active_record.observers = :observist unless ENV['SAFE']

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  #---[ Custom libraries ]------------------------------------------------

  # Load custom libraries before "config/initializers" run.
  $LOAD_PATH.unshift("#{RAILS_ROOT}/lib")

  # Read secrets
  require 'secrets_reader'
  SECRETS = SecretsReader.read

  # Read theme
  require 'theme_reader'
  THEME_NAME = ThemeReader.read
  Kernel.class_eval do
    def theme_file(filename)
      return "#{RAILS_ROOT}/themes/#{THEME_NAME}/#{filename}"
    end
  end

  # Read settings
  require 'settings_reader'
  SETTINGS = SettingsReader.read(
    theme_file("settings.yml"), {
      'public_url' => 'http://change_your/settings.yml/',
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
    :session_key => SECRETS.session_name || "openproposals",
    :secret => SECRETS.session_secret,
  }

  # Setup cache
  require 'rails_cache_configurator'
  RailsCacheConfigurator.apply(config)
end
