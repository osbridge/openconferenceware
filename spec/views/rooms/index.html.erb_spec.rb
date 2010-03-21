require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/rooms/index.html.erb" do
  include RoomsHelper

  before(:each) do
    @event = stub_current_event!
    assigns[:rooms] = [
      stub_model(Room, :name => "Foo room", :event => @event),
      stub_model(Room, :name => "Bar room", :event => @event),
    ]
  end

  it "should render list of rooms" do
    render "/rooms/index.html.erb"
  end
end

