# Customizations made to RSpec environment

#---[ Settings ]--------------------------------------------------------

# Disable the shared fragment rendering
SharedFragmentHelper.enabled = false

#---[ Libraries ]-------------------------------------------------------

include AuthenticatedTestHelper

# Load factory girl and all her factories in 'spec/factories/':
require 'factory_girl'
Dir["#{RAILS_ROOT}/spec/factories/*.rb"].each{|filename| require filename}

#---[ Functions ]-------------------------------------------------------

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
  controller.stub!(
    :get_current_event_and_assignment_status => [event, status],
    :assigned_event => event,
    :assigned_events => events)
  assigns[:event] = event
  assigns[:events] = events
  Event.stub!(:lookup).and_return do |*args|
    key = args.pop
    key ? event : events
  end
  return event
end

#---[ fin ]-------------------------------------------------------------
