require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  fixtures :all

  context "when accepting proposals" do
    it "should accept proposals for future" do
      events(:closed).accepting_proposals?.should be_false
    end

    it "should not accept proposals for past" do
      events(:open).accepting_proposals?.should be_true
    end
  end
  
  describe "when determining if proposal status is visible" do 
    before :each do
      @event = Event.new
    end
    
    it "should not be published by default" do
      @event.proposal_status_published.should be_false
    end
    
    it "should be possible to publish proposal statuses" do
      @event.proposal_status_published = true
      @event.proposal_status_published.should be_true
    end
  end

  context "when finding current event" do
    it "should use cache" do
      event = events(:open)
      Event.should_receive(:fetch_object).with("event_current").and_return(event)
      Event.should_not_receive(:current_by_deadline)

      Event.current.should == event
    end

    it "should use find if not in cache" do
      event = events(:open)
      RAILS_CACHE.delete_matched(//) # Everything
      Event.should_receive(:current_by_deadline).and_return(event)

      Event.current.should == event
    end
  end

  context "when expiring cache" do
    it "should expire current" do
      RAILS_CACHE.should_receive(:delete).with(Event::EVENT_CURRENT_CACHE_KEY)

      Event.expire_current
    end

    it "should expire current through expire_cache" do
      Event.should_receive(:expire_current)

      Event.expire_cache
    end
  end
end
