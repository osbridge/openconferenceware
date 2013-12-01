require 'spec_helper'

describe "proposals/_room_control.html.erb" do
  it "should render a selector for choosing a room" do
    rooms = [
      stub_model(Room, id: 1, name: "First Room"),
      stub_model(Room, id: 2, name: "Second Room"),
    ]

    event = stub_model(Event)
    event.stub(:rooms).and_return(rooms)

    proposal = stub_model(Proposal, room: rooms.first, room_id: rooms.first.id, event: event)
    assign(:proposal, proposal)
    render
    rendered.should have_selector("select[name='proposal[room_id]']") do |node|
      node.should have_selector("option[value='']", text: "- None -")
      node.should have_selector("option[value='1'][selected]", text: "First Room")
      node.should have_selector("option[value='2']", text: "Second Room")
    end
  end
end

