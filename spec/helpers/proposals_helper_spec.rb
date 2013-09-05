require 'spec_helper'

describe ProposalsHelper do
  describe "traversal" do
    before do
      @event = Factory :populated_event
      @proposal1 = proposal_for_event(@event)
      @proposal2 = proposal_for_event(@event)
    end
    
    describe "#next_proposal_path_from" do
      it "should return a link to the next proposal when it exists" do
        helper.next_proposal_path_from(@proposal1).should == proposal_path(@proposal2)
      end

      it "should return nil when this is the last proposal" do
        helper.next_proposal_path_from(@proposal2).should be_nil
      end
    end

    describe "#previous_proposal_path_from" do
      it "should return a link to the previous proposal when it exists" do
        helper.previous_proposal_path_from(@proposal2).should == proposal_path(@proposal1)
      end

      it "should return nil when this is the first proposal" do
        helper.previous_proposal_path_from(@proposal1).should be_nil
      end
    end
  end
end
