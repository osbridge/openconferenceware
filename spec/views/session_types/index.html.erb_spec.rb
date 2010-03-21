require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/session_types/index.html.erb" do
  include SessionTypesHelper
  
  before(:each) do
    @event = stub_current_event!
    assigns[:session_types] = [
      stub_model(SessionType, :event => @event),
      stub_model(SessionType, :event => @event)
    ]
  end

  it "should render list of session_types" do
    render "/session_types/index.html.erb"
  end
end

