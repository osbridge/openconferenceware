require 'spec_helper'

describe SelectorVote do
  it "should create a record if given valid attributes" do
    event = Factory(:populated_event)
    proposal = proposal_for_event(event)

    vote = proposal.selector_votes.new(:rating => 1, :comment => "meh")
    vote.user = Factory(:user)
    vote.save!
  end
end
