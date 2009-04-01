require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/proposals/_transition_control.html.erb" do
  it "should render a state changing select menu with valid events and destination label" do
    proposal = stub_model(Proposal, :aasm_events_for_current_state => [:accept, :reject])
    assigns[:proposal] = proposal
    render "/proposals/_transition_control.html.erb"
    response.should have_tag("select[name='proposal[transition]']") do
      with_tag "option[value=]", "(currently 'Proposed')"
      with_tag "option[value=accept]", "Accept"
      with_tag "option[value=reject]", "Reject"
    end
  end
end
