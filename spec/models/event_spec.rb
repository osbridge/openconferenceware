require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  describe "when accepting proposals" do
    fixtures :all

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

  describe "when finding current event" do
    fixtures :all

    it "should use cache" do
      event = events(:open)
      Event.should_receive(:fetch_object).with("event_current").and_return(event)
      Event.should_not_receive(:current_by_deadline)

      Event.current.should == event
    end

    it "should use find if not in cache" do
      event = events(:open)
      Rails.cache.should_receive(:read).any_number_of_times.and_return(nil)

      Observist.expire

      Event.should_receive(:current_by_settings).and_return(nil)
      Event.should_receive(:current_by_deadline).and_return(event)

      Event.current.should == event
    end

    it "should return nil if no current event is available" do
      Event.destroy_all
      Event.current.should be_nil
    end
  end

  describe "when expiring cache" do
    it "should expire current" do
      RAILS_CACHE.should_receive(:delete).with(Event::EVENT_CURRENT_CACHE_KEY)

      Event.expire_current
    end

    it "should expire current through expire_cache" do
      Event.should_receive(:expire_current)

      Event.expire_cache
    end
  end

  describe "#populated_proposals" do
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

  describe "#dates" do
    it "should return range between start_date and end_date" do
      start_date = Date.today + 1.week
      end_date   = Date.today + 2.weeks
      event = Event.new(:start_date => start_date, :end_date => end_date)

      event.dates.should == (start_date..end_date).to_a
    end

    it "should return empty array if no dates" do
      Event.new().dates.should == []
    end

    it "should return empty array if no start_date" do
      Event.new(:end_date => Date.today).dates.should == []
    end

    it "should return empty array if no end_date" do
      Event.new(:start_date => Date.today).dates.should == []
    end
  end
end
