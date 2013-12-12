require 'spec_helper'

describe "open_conference_ware/rooms/show.html.erb" do
  include OpenConferenceWare::RoomsHelper
  before(:each) do
    assign(:room, stub_model(Room))
    @event = stub_current_event!
    view.stub(:admin?).and_return(false)
  end

  it "should render a room" do
    render
  end
end
