# Customizations made to RSpec environment

#---[ Settings ]--------------------------------------------------------

# Use spec-specific settings
require 'ocw_config'

#---[ Libraries ]-------------------------------------------------------

include AuthenticatedTestHelper

require 'factory_girl'
require 'database_cleaner'
require 'capybara/rspec'

OpenConferenceWare::Engine.routes.default_url_options[:host] = 'test.host'

# rspec
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include OpenConferenceWare::Engine.routes.url_helpers
  config.use_transactional_fixtures = false

  config.before(:suite) do
    if ActiveRecord::Base.configurations[Rails.env]['adapter'] == "sqlite3"
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.clean_with(:truncation)

  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # List all of the OpenConferenceWare models, so we can make namespaced tests a bit nicer
  models = %w(Authentication Comment Event Proposal Room Schedule ScheduleItem SelectorVote SessionType Snippet Track User UserFavorite)

  # Fixture file names need to match the database table names.
  # Set the corresponding OpenConferenceWare model for each of them.
  config.before(:all) do
    self.class.set_fixture_class(
      Hash[models.map do |model|
        ["open_conference_ware_#{model.underscore.pluralize}", OpenConferenceWare.const_get(model)]
      end]
    )
  end

  # Stub un-namespaced constants for OpenConferenceWare models, so that we can
  # refer to things like User, instead of OpenConferenceWare::User in specs.
  config.before(:each) do
    models.each do |model|
      stub_const(model, OpenConferenceWare.const_get(model))
    end
  end
end

#---[ Functions ]-------------------------------------------------------

module OCWHelpers
  # Save the response.body to "/tmp/response.html", to aid manual debugging.
  def save_body
    filename = "/tmp/response.html"
    bytes = File.open(filename, "w+"){|h| h.write(response.body)}
    return [filename, bytes]
  end

  # Stub the +controller+ to provide the current event. If the +event+ or
  # +status+ aren't provided, reasonable defaults will be used.
  #
  # Options:
  # * event: Event object to use, else a mock will be generated.
  # * events: Array of events to use, else the :event or its mock will be used.
  # * status: Assignment status to use, else :assigned_to_current will be used.
  def stub_current_event!(opts={})
    controller = opts[:controller] || @controller
    event = opts[:event] || stub_model(Event, id: 1, title: "Current Event", slug: 'current')
    events = opts[:events] || [event]
    status = opts[:status] || :assigned_to_current
    controller.stub(
      get_current_event_and_assignment_status: [event, status],
      assigned_event: event,
      assigned_events: events)

    if self.respond_to?(:assign)
      assign(:event, event)
      assign(:events, events)
    end

    Event.stub(:lookup).and_return do |*args|
      key = args.pop
      key ? event : events
    end
    return event
  end

  def stub_settings_accessors_on(view)
    view.stub(:can_edit?).and_return(false)
    view.stub(:selector?).and_return(false)
    view.stub(:admin?).and_return(false)
    view.stub(:current_user_is_proposal_speaker?).and_return(false)
    view.stub(:proposal_statuses?).and_return(true)
    view.stub(:multiple_presenters?).and_return(true)
    view.stub(:user_profiles?).and_return(true)
    view.stub(:event_tracks?).and_return(true)
    view.stub(:event_session_types?).and_return(true)
    view.stub(:proposal_excerpts?).and_return(true)
    view.stub(:event_rooms?).and_return(true)
    view.stub(:proposal_speaking_experience?).and_return(true)
    view.stub(:schedule_visible?).and_return(true)
  end
end

RSpec.configure do |c|
  c.include OCWHelpers
end

#---[ fin ]-------------------------------------------------------------
