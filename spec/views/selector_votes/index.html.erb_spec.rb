require 'spec_helper'

describe "/selector_votes/index.html.erb" do
  include SelectorVotesHelper

  before(:each) do
    @user1 = Factory :selector
    @user2 = Factory :selector

    @event = Factory :populated_event

    @proposal1 = proposal_for_event(@event)
    @proposal2 = proposal_for_event(@event)

    @selector_vote1 = @proposal1.selector_votes.create :user => @user1, :rating => 1, :comment => "Meh."
    @selector_vote2 = @proposal1.selector_votes.create :user => @user2, :rating => 5, :comment => "Yay!"

    @comment1 = @proposal1.comments.create :email => "foo@.bar.com", :message => "Hi!"

    assigns[:event] = @event
    assigns[:proposals] = [@proposal1, @proposal2]

    render
  end

  describe "result" do
    it "should include proposal with selector votes" do
      have_selector ".proposal_#{@proposal1.id}"
    end

    it "should include proposal without selector votes" do
      have_selector ".proposal_#{@proposal2.id}"
    end

    it "should include selector vote for a proposal" do
      have_selector ".proposal_#{@proposal1.id} .selector_vote_#{@selector_vote1}"
    end

    it "should include comment for a proposal" do
      have_selector ".proposal_#{@proposal1.id} .comment_#{@comment1}"
    end
  end
end
