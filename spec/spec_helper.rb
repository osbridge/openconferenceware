# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

#---[ Customizations ]--------------------------------------------------

include AuthenticatedTestHelper

# Save the response.body to "/tmp/response.html", to aid manual debugging.
def save_body
  filename = "/tmp/response.html"
  bytes = File.open(filename, "w+"){|h| h.write(response.body)}
  return [filename, bytes]
end

# Stub the +controller+ to provide the current event. If the +event+ or
# +status+ aren't provided, reasonable defaults will be used.
def stub_current_event!(opts={})
  controller = opts[:controller] || @controller
  event = opts[:event] || stub_model(Event, :id => 1, :title => "Event 1")
  status = opts[:status] || :assigned_to_current
  controller.stub!(:get_current_event_and_assignment_status).and_return([event, status])
  assigns[:event] = event
  return event
end
