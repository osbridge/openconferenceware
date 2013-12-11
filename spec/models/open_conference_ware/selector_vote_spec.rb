require 'spec_helper'

describe SelectorVote do
  it "should build a valid record if given valid attributes" do
    event = create(:populated_event)
    proposal = proposal_for_event(event)

    vote = proposal.selector_votes.new(rating: 1, comment: "meh")
    vote.user = build(:user)
    vote.should be_valid
  end
end
