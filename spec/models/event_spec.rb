require 'spec_helper'

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

    it "should use find event" do
      event = events(:open)

      Event.should_receive(:current_by_settings).and_return(nil)
      Event.should_receive(:current_by_deadline).and_return(event)

      Event.current.should == event
    end

    it "should return nil if no current event is available" do
      Event.destroy_all
      Event.current.should be_nil
    end
  end

  describe "#populated_proposals" do
    fixtures :all

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
      start_date = Time.now.utc.to_date + 1.week
      end_date   = Time.now.utc.to_date + 2.weeks
      event = Event.new(:start_date => start_date, :end_date => end_date)

      event.dates.should == Array(start_date..end_date)
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

  describe "#parent_or_self" do
    def create_event(opts)
      Event.create!({:deadline => Time.now}.merge(opts))
    end

    it "should find a parent when there is one" do
      parent = create_event :title => "Mommy!", :slug => "mommy", :open_text => "Open!", :closed_text => "Closed!"
      child  = create_event :title => "Baby!",  :slug => "baby",  :open_text => "Open!", :closed_text => "Closed!", :parent => parent

      child.parent_or_self.should == parent
    end

    it "should find self when there's no parent" do
      event = create_event :title => "Event!", :slug => "event", :open_text => "Open!", :closed_text => "Closed!"

      event.parent_or_self.should == event
    end
  end

  describe "#related_proposals" do
    before :each do
      Event.destroy_all

      @parent    = Factory :populated_event
      @event     = Factory :populated_event, :parent => @parent
      @child     = Factory :populated_event, :parent => @event
      @unrelated = Factory :populated_event

      @event_proposal     = proposal_for_event @event
      @parent_proposal    = proposal_for_event @parent
      @child_proposal     = proposal_for_event @child
      @unrelated_proposal = proposal_for_event @unrelated

      @proposals = [@event_proposal, @parent_proposal, @child_proposal, @unrelated_proposal]

      @event.reload

      @related = @event.related_proposals @proposals
    end

    it "should find the event's proposals" do
      @related.should include(@event_proposal)
    end

    it "should find the event parent's proposals" do
      @related.should include(@parent_proposal)
    end

    it "should find the event children's proposals" do
      @related.should include(@child_proposal)
    end

    it "should not find unrelated event's proposals" do
      @related.should_not include(@unrelated_proposal)
    end
  end

  describe "#descendents" do
    before :each do
      @parent     = Factory :populated_event
      @event      = Factory :populated_event, :parent => @parent
      @child      = Factory :populated_event, :parent => @event
      @grandchild = Factory :populated_event, :parent => @child
      @unrelated  = Factory :populated_event

      @descendents = @event.descendents
    end

    it "should include an event's children" do
      @descendents.should include(@child)
    end

    it "should include an event's children's children" do
      @descendents.should include(@grandchild)
    end

    it "should not include parent" do
      @descendents.should_not include(@parent)
    end

    it "should not include unrelated event" do
      @descendents.should_not include(@unrelated)
    end
  end

  describe "#family" do
    before :each do
      @parent     = Factory :populated_event
      @stepchild  = Factory :populated_event, :parent => @parent
      @event      = Factory :populated_event, :parent => @parent
      @child      = Factory :populated_event, :parent => @event
      @grandchild = Factory :populated_event, :parent => @child
      @unrelated  = Factory :populated_event

      @family = @event.family
    end

    it "should include an event's children" do
      @family.should include(@child)
    end

    it "should include an event's children's children" do
      @family.should include(@grandchild)
    end

    it "should include parent" do
      @family.should include(@parent)
    end

    it "should include step-child" do
      @family.should include(@stepchild)
    end

    it "should not include unrelated event" do
      @family.should_not include(@unrelated)
    end
  end

end
