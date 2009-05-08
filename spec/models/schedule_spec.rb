require File.dirname(__FILE__) + '/../spec_helper'

describe Schedule do
  fixtures :all

  before(:each) do
    @sessions = Proposal.scheduled.located.all
  end

  describe "new" do
    it "should initialize from an array of proposals" do
      items = @sessions
      items.should_not be_empty

      schedule = Schedule.new(items)

      schedule.items.should == items
    end
  end
end

class SchedulableThingy
  include Schedulable
end

describe SchedulableThingy do
  before(:each) do
    @thingy = SchedulableThingy.new
    @duration = 1.hour
    @time1 = Time.now
    @time2 = @time1 + @duration
  end

  describe "when start_time is set" do
    before(:each) do
      @thingy.start_time = @time1
    end

    it "should set start_time" do
      @thingy.start_time.should == @time1
    end

    it "should set duration from end_time" do
      @thingy.end_time = @time2
      @thingy.duration.should == @duration
    end

    it "should set end_time from duration" do
      @thingy.duration = @duration
      @thingy.end_time.should == @time2
    end

    it "should fail if end_time is before the set start_time" do
      lambda { @thingy.end_time = @time1 - 1.hour }.should raise_error(ArgumentError)
    end

    it "should fail if duration is negative" do
      lambda { @thingy.duration = -42 }.should raise_error(ArgumentError)
    end
  end

  describe "when start_time is not set" do
    it "should fail to set end_time if start_time isn't set" do
      lambda { @thingy.end_time = @time2 }.should raise_error(ArgumentError)
    end

    it "should fail to set duration if start_time isn't set" do
      lambda { @thingy.duration = -42 }.should raise_error(ArgumentError)
    end
  end
end
