require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/proposals/_transition_control.html.erb" do
  it "should render a state changing select menu with valid events and destination label" do
    proposal = stub_model(Proposal, :aasm_events_for_current_state => [:accept, :reject])
    assigns[:proposal] = proposal
    render "/proposals/_transition_control.html.erb"
    response.should have_selector("select[name='proposal[transition]']") do |node|
      node.should have_selector("option[value='']", :content => "(currently 'Proposed')")
      node.should have_selector("option[value='accept']", :content => "Accept")
      node.should have_selector("option[value='reject']", :content => "Reject")
    end
  end
end
