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
      Observist.expire
      Event.should_receive(:current_by_deadline).and_return(event)

      Event.current.should == event
    end

    it "should return nil if no current event is available" do
      Event.destroy_all
      Event.current.should be_nil
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

  context "populated_proposals" do
    fixtures :events, :proposals

    before(:each) do
      @event = events(:open)
    end

    it "should get proposals and sessions for :proposals" do
      records = @event.populated_proposals(:proposals).all

      records.select(&:confirmed?).should_not be_empty
      records.reject(&:confirmed?).should_not be_empty
    end

    it "should get just sessions for :sessions" do
      records = @event.populated_proposals(:sessions).all
      
      records.select(&:confirmed?).should_not be_empty
      records.reject(&:confirmed?).should be_empty
    end

    it "should fail to get invalid kind" do
      lambda { @event.populated_proposals(:omg) }.should raise_error(ArgumentError)
    end
  end
end
