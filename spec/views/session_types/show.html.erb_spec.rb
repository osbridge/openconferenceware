require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/session_types/show.html.erb" do
  include SessionTypesHelper
  before(:each) do
    assigns[:session_type] = @session_type = stub_model(SessionType)

    @event = stub_model(Event,
      :id => 1,
      :title => "Event 1"
    )

    @controller.stub!(:get_current_event_and_assignment_status).and_return([@event, :assigned_to_current])
  end

  it "should render attributes in <p>" do
    render "/session_types/show.html.erb"
  end
end

