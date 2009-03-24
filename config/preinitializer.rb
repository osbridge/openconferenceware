# Standard librarires
require 'csv'
require 'ostruct'
require 'stringio'
require 'uri'
require 'fileutils'

# Gems
require 'rubygems'

# See also config/initializers/libraries

# Phusion Passenger cannot see Rails::Boot here, so don't apply the monkey
# patch for it. Normal Ruby interpreters will, however, be able to use it.
if defined?(Rails::Boot)
  # Monkey patch for Rails 2.1.x so that "rake gems:install" will work by making
  # it not load the files that depend on libraries that aren't yet installed.
  # http://rails.lighthouseapp.com/projects/8994/tickets/1286-observed-model-dependent-on-app-initializer-causes-rake-gemsinstall-failure
  Rails::Boot.class_eval do
    def run
      load_initializer
      Rails::Initializer.class_eval do
        def prepare_dispatcher
          return unless configuration.frameworks.include?(:action_controller) && @gems_dependencies_loaded
          require 'dispatcher' unless defined?(::Dispatcher)
          Dispatcher.define_dispatcher_callbacks(configuration.cache_classes)
          Dispatcher.new(Rails.logger).send :run_callbacks, :prepare_dispatch
        end
      end
      Rails::Initializer.run(:set_load_path)
    end
  end
end
