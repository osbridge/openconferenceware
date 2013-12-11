require 'spec_helper'

describe "open_conference_ware/session_types/show.html.erb" do
  include OpenConferenceWare::SessionTypesHelper
  before(:each) do
    assign(:session_type, stub_model(SessionType))
    view.stub(:admin?).and_return(false)

    @event = stub_current_event!(controller: view)

    view.stub(:schedule_visible?).and_return(true)
  end

  it "should render attributes in <p>" do
    render
  end
end
