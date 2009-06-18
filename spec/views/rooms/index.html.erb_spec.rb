require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/rooms/index.html.erb" do
  include RoomsHelper

  before(:each) do
    assigns[:rooms] = [
      stub_model(Room, :name => "Foo room"),
      stub_model(Room, :name => "Bar room"),
    ]
  end

  it "should render list of rooms" do
    render "/rooms/index.html.erb"
  end
end

