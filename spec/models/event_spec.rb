require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  fixtures :events

  context "when accepting proposals" do
    it "should accept proposals for future" do
      events(:closed).accepting_proposals?.should be_false
    end

    it "should not accept proposals for past" do
      events(:open).accepting_proposals?.should be_true
    end
  end

  context "when finding current event" do
    it "should use cache" do
      event = events(:open)
      RAILS_CACHE.should_receive(:fetch_object).with("event_current").and_return(event)
      Event.should_not_receive(:current_by_snippet)
      Event.should_not_receive(:current_by_deadline)

      Event.current.should == event
    end

    it "should use snippet if not in cache" do
      event = events(:open)
      snippet_key = 42
      snippet = mock(Snippet, :value => snippet_key)
      RAILS_CACHE.delete_matched(//) # Everything
      Snippet.should_receive(:lookup).with(Event::EVENT_CURRENT_ID_SNIPPET).and_return(snippet)
      Event.should_receive(:lookup).with(snippet_key).and_return(event)
      Event.should_not_receive(:current_by_deadline)

      Event.current.should == event
    end

    it "should use find if not in cache or snippet" do
      event = events(:open)
      RAILS_CACHE.delete_matched(//) # Everything
      Event.should_receive(:current_by_snippet).and_return(nil)
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
