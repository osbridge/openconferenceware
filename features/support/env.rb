# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures
Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling 
                              # (e.g. rescue_action_in_public / rescue_responses / rescue_from)

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'

# From http://wiki.github.com/aslakhellesoy/cucumber/fixtures
Before do
  Fixtures.reset_cache
  fixtures_folder = File.join(RAILS_ROOT, 'spec', 'fixtures')
  fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
  Fixtures.create_fixtures(fixtures_folder, fixtures)
end

# Return the boolean for the given string, e.g., "y" is true.
def boolean_for(truth)
  case truth
  when true, /^y/i, /^t/i
    true
  else
    false
  end
end

