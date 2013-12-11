require 'spec_helper'

describe "proposals/_transition_control.html.erb" do
  it "should render a state changing select menu with valid events and destination label" do
    proposal = stub_model(Proposal, aasm_events_for_current_state: [:accept, :reject])
    assign(:proposal, proposal)
    render
    rendered.should have_selector("select[name='proposal[transition]']") do |node|
      node.should have_selector("option[value='']", text: "(currently 'Proposed')")
      node.should have_selector("option[value='accept']", text: "Accept")
      node.should have_selector("option[value='reject']", text: "Reject")
    end
  end
end
