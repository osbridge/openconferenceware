require 'spec_helper'

describe "/rooms/show.html.erb" do
  include RoomsHelper
  before(:each) do
    assigns[:room] = @room = stub_model(Room)
    @event = stub_current_event!
  end

  it "should render attributes in <p>" do
    render "/rooms/show.html.erb"
  end
end

