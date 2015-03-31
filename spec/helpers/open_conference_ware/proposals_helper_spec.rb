require 'spec_helper'

describe OpenConferenceWare::ProposalsHelper do
  describe "traversal" do
    before :each do
      allow(view).to receive(:selector?).and_return(false)
      add_all_helpers_to(view)
      @event = create :populated_event
      @proposal1 = proposal_for_event(@event)
      @proposal2 = proposal_for_event(@event)
    end

    describe "#next_proposal_path_from" do
      context "as a mortal" do
        it "should return a link to the next proposal when it exists" do
          helper.next_proposal_path_from(@proposal1).should == view.proposal_path(@proposal2)
        end

        it "should return nil when this is the last proposal" do
          helper.next_proposal_path_from(@proposal2).should be_nil
        end
      end
    end

    describe "#previous_proposal_path_from" do
      context "as a mortal" do
        it "should return a link to the previous proposal when it exists" do
          helper.previous_proposal_path_from(@proposal2).should == view.proposal_path(@proposal1)
        end

        it "should return nil when this is the first proposal" do
          helper.previous_proposal_path_from(@proposal1).should be_nil
        end
      end
    end
  end
end
