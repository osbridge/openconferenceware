require 'spec_helper'

describe SelectorVote do
  it "should create a record if given valid attributes" do
    event = Factory(:populated_event)
    proposal = proposal_for_event(event)
    SelectorVote.create!(:user => Factory(:user), :proposal => proposal, :rating => 1)
  end
end
