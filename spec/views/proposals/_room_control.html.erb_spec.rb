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
    response.should have_tag("select[name='proposal[room_id]']") do
      with_tag "option[value=]", "- None -"
      with_tag "option[value=1][selected]", "First Room"
      with_tag "option[value=2]", "Second Room"
    end
  end
end

