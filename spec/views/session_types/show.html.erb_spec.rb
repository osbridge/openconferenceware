require 'spec_helper'

describe "session_types/show.html.erb" do
  include SessionTypesHelper
  before(:each) do
    assign(:session_type, stub_model(SessionType))

    @event = stub_current_event!(:controller => template)

    template.stub(:schedule_visible?).and_return(true)
  end

  it "should render attributes in <p>" do
    render
  end
end

