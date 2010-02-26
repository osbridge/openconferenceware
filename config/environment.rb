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
RAILS_GEM_VERSION = '~> 2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Gems that are selectively loaded:
  config.gem 'sqlite3-ruby', :lib => false # For default database driver
  config.gem 'ruby-openid',  :lib => false # For open_id_authentication
  config.gem 'facets',       :lib => false # For initializers/dependencies.rb
  config.gem 'right_aws',    :lib => false # For paperclip

  # Gems only used for development and test:
  if %w[development test].include?(RAILS_ENV) then
    config.gem 'rspec',            :version => '~> 1.3.0', :lib => false
    config.gem 'rspec-rails',      :version => '~> 1.3.0', :lib => false
    config.gem 'cucumber',         :version => '~> 0.6.2', :lib => false
    config.gem 'cucumber-rails',   :version => '~> 0.2.4', :lib => false
    config.gem 'webrat',           :version => '~> 0.7.0', :lib => false
    config.gem 'database_cleaner', :version => '~> 0.4.3', :lib => false
  end

  # Provide profiling at '/newrelic' if requested, e.g.: NEWRELIC=1 ./script/server
  config.gem 'newrelic_rpm' if ENV['NEWRELIC']

  # Gems to load into the environment:
  config.gem 'acts-as-taggable-on', :version => '~> 1.1.5'
  config.gem 'paperclip',           :version => '~> 2.3.1'
  config.gem 'aasm',                :version => '~> 2.1.5'
  config.gem 'gchartrb',            :lib => 'google_chart'
  config.gem 'vpim',                :lib => 'vpim/icalendar'
  config.gem 'RedCloth'
  config.gem 'color'
  config.gem 'deep_merge'
  config.gem 'hpricot'

  # Gems in vendor/gems
  config.gem 'comma'
  config.gem 'rwikibot'

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
    theme_file('settings.yml'), {
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
    :session_key => SECRETS.session_name || 'openproposals',
    :secret => SECRETS.session_secret,
  }

  # Setup cache
  require 'rails_cache_configurator'
  RailsCacheConfigurator.apply(config)
end
