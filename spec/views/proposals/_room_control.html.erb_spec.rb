require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/proposals/_room_control.html.erb" do
  it "should render a selector for choosing a room" do
    rooms = [
      stub_model(Room, :id => 1, :name => "First Room"),
      stub_model(Room, :id => 2, :name => "Second Room"),
    ]
    event = stub_model(Event, :rooms => rooms)
    proposal = stub_model(Proposal, :room => rooms.first, :room_id => rooms.first.id, :event => event)
    assigns[:proposal] = proposal
    render "/proposals/_room_control.html.erb"
    response.should have_selector("select[name='proposal[room_id]']") do |node|
      node.should have_selector("option[value='']", :content => "- None -")
      node.should have_selector("option[value='1'][selected]", :content => "First Room")
      node.should have_selector("option[value='2']", :content => "Second Room")
    end
  end
end

