# Customizations made to RSpec environment

#---[ Settings ]--------------------------------------------------------

# Use spec-specific settings
# NOTE: The marshal_load/marshal_dump calls are just to avoid constant redefinition error.
SETTINGS.marshal_load(SettingsReader.read('spec/settings.yml').marshal_dump)

#---[ Libraries ]-------------------------------------------------------

include AuthenticatedTestHelper

# Load factory girl and all her factories in 'spec/factories/':
require 'factory_girl'

# rspec
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

OmniAuth.config.add_mock(:open_id, {:uid => 'http://openconferenceware.org'})

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
  # * :event => Event object to use, else a mock will be generated.
  # * :events => Array of events to use, else the :event or its mock will be used.
  # * :status => Assignment status to use, else :assigned_to_current will be used.
  def stub_current_event!(opts={})
    controller = opts[:controller] || @controller
    event = opts[:event] || stub_model(Event, :id => 1, :title => "Current Event", :slug => 'current')
    events = opts[:events] || [event]
    status = opts[:status] || :assigned_to_current
    controller.stub(
      :get_current_event_and_assignment_status => [event, status],
      :assigned_event => event,
      :assigned_events => events)

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
