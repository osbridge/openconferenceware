require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProposalsHelper do

  describe "rendering state change select widget" do
    before :each do
      @proposal = Proposal.new
    end

    it "should render a state changing select menu with valid events and destination label" do
      @proposal.stub!(:aasm_events_for_current_state).
         and_return [:accept, :reject]
      html = helper.state_change_select(@proposal)
      html.should have_tag("select[name='proposal[transition]']") do
        with_tag 'option[value=]', ''
        with_tag 'option[value=accept]', "Accept"
        with_tag 'option[value=reject]', "Reject"
      end
    end

    it "should give a descriptive message if no events are available" do
      @proposal.stub!(:aasm_events_for_current_state).
         and_return []
      html = helper.state_change_select(@proposal)
      html.should_not have_tag("select[name='proposal[transition]']")
      html.should =~ /no valid/i
    end
  end
end
