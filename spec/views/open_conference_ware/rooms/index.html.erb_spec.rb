require 'spec_helper'

describe "open_conference_ware/rooms/index.html.erb" do
  include OpenConferenceWare::RoomsHelper

  before(:each) do
    @event = stub_current_event!
    assign(:rooms, [
      stub_model(Room, name: "Foo room", event: @event),
      stub_model(Room, name: "Bar room", event: @event),
    ])
    view.stub(:admin?).and_return(false)
  end

  it "should render list of rooms" do
    render
  end
end
