require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module OpenConferenceWare
  class Application < Rails::Application
    # Load from "/lib"
    $LOAD_PATH << Rails.root.join('lib')

    config.autoload_paths += [
      # App
      Rails.root.join('app','mixins'),
      Rails.root.join('app','observers'),
      Rails.root.join('app','renderers'),
    ]

    config.eager_load_paths += [
      Rails.root.join('lib')
    ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :cache_watcher

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    config.before_initialize do
      # Read secrets
      require 'secrets_reader'
      ::SECRETS = SecretsReader.read

      # Read settings
      require 'settings_reader'
      ::SETTINGS = SettingsReader.read(
        Rails.root.join("config", "settings.yml"), {
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

      # Setup default host for use in mailers
      config.action_mailer.default_url_options = { :host => SETTINGS.mailer_host }

      # Set timezone for Rails
      config.time_zone = SETTINGS.timezone
    end
  end
end
