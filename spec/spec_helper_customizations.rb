# Extra libraries and features imported into "spec/spec_helper.rb"

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
