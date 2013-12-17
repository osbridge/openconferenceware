require 'spec_helper'

describe "open_conference_ware/proposals/_transition_control.html.erb" do
  it "should render a state changing select menu with valid events and destination label" do
    aasm = double("aasm", events: [:accept, :reject], current_state: :proposed)
    proposal = stub_model(Proposal, aasm: aasm)
    assign(:proposal, proposal)
    render
    rendered.should have_selector("select[name='proposal[transition]']") do |node|
      node.should have_selector("option[value='']", text: "(currently 'Proposed')")
      node.should have_selector("option[value='accept']", text: "Accept")
      node.should have_selector("option[value='reject']", text: "Reject")
    end
  end
end
