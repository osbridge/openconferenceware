require File.dirname(__FILE__) + '/../spec_helper'

describe Schedule do
  fixtures :all

  before(:each) do
    @sessions = []
    @sessions << @rakudo_session     = proposals(:rakudo_session)

    # Same time, different duration ------------------------------------\
      @sessions << @drizzle_session    = proposals(:drizzle_session)    #
      @sessions << @postgresql_session = proposals(:postgresql_session) #
    # ------------------------------------------------------------------/

    # Same time, same duration -----------------------------------------\
      @sessions << @cloud_session      = proposals(:cloud_session)       #
      @sessions << @business_session   = proposals(:business_session)    #
    # ------------------------------------------------------------------/

    @sessions.should_not be_empty
    @schedule = Schedule.new(@sessions)
  end

  it "should not initialize from unknown types" do
    lambda { Schedule.new(:omg) }.should raise_error(TypeError)
  end

  it "should initialize from an Event" do
    schedule = Schedule.new(events(:open))
    schedule.days.should_not be_empty
    schedule.sections.should_not be_empty
    schedule.slices.should_not be_empty
    schedule.blocks.should_not be_empty
    schedule.items.should_not be_empty
  end

  it "should initialize from an array of proposals" do
    @schedule.items.sort_by(&:title).should == @sessions.sort_by(&:title)
  end

  describe "is a container for days and" do
    before do
      @days = @schedule.days
    end

    it "thus, should have days" do
      @days.should_not be_blank
      @days.first.should be_a_kind_of(ScheduleDay)
    end

    describe "days are containers for sections and" do
      before do
        @sections = @days.first.sections
      end

      it "thus, they should have sections" do
        @sections.should_not be_blank
        @sections.first.should be_a_kind_of(ScheduleSection)
      end

      describe "sections are containers for slices and" do
        before do
          @slices = @sections.first.slices
        end

        it "thus, they should have slices" do
          @slices.should_not be_blank
          @slices.first.should be_a_kind_of(ScheduleSlice)
        end

        describe "blocks are containers for blocks and" do
          before do
            @blocks = @slices.first.blocks
          end

          it "thus, they should have blocks" do
            @blocks.should_not be_blank
            @blocks.first.should be_a_kind_of(ScheduleBlock)
          end

          describe "blocks are containers for items and" do
            before do
              @items = @blocks.first.items
            end

            it "thus, they should have items" do
              @items.should_not be_blank
              @items.first.should respond_to(:start_time)
            end
          end
        end
      end

      it "thus, they should have access to their children's slices" do
        @days.first.slices.first.should be_a_kind_of(ScheduleSlice)
      end

      it "thus, they should have access to their children's blocks" do
        @days.first.blocks.first.should be_a_kind_of(ScheduleBlock)
      end
    end
  end

  describe "(given a valid set of items to process)" do

    describe "when building a schedule" do
      before(:each) do
        @days = @schedule.days
        @sections = @schedule.sections
        @slices = @schedule.slices
        @blocks = @schedule.blocks

        @postgresql_block = @blocks.select{|block| block.items.include?(@postgresql_session)}.first
        @drizzle_block = @blocks.select{|block| block.items.include?(@drizzle_session)}.first
        @rakudo_block = @blocks.select{|block| block.items.include?(@rakudo_session)}.first
        @cloud_block = @blocks.select{|block| block.items.include?(@cloud_session)}.first

        @postgresql_slice = @slices.select{|slice| slice.blocks.include?(@postgresql_block)}.first
        @drizzle_slice = @slices.select{|slice| slice.blocks.include?(@drizzle_block)}.first

        @rakudo_section = @sections.select{|section| section.blocks.include?(@rakudo_block)}.first
        @postgresql_section = @sections.select{|section| section.blocks.include?(@postgresql_block)}.first
      end

      it "should create a day for each day represented in the input set" do
        @days.map(&:date).sort.should == @sessions.map{|session| session.start_time.to_date}.uniq.sort
      end

      it "each item should be contained in one and only one block" do
        @sessions.each do |session|
          @blocks.select{|block| block.items.include?(session)}.size.should == 1
        end
      end

      it "should set the time boundries for each block equal to those of its items" do
        @blocks.each do |block|
          block.items.each do |item|
            block.start_time.should == item.start_time
            block.duration.should == item.duration
          end
        end
      end

      describe "should group items that share a start time and duration into a block:" do
        it "The drizzle session should be alone in its block" do
          @drizzle_block.items.should == [@drizzle_session]
        end

        it "The cloud session should be in the same block as the business session" do
          @cloud_block.items.size.should == 2
          @cloud_block.items.should include(@business_session)
        end
      end

      describe "should group overlapping blocks into sections:" do
        it "The rakudo block should be alone in its section" do
          @rakudo_section.blocks.should == [@rakudo_block]
        end

        it "The postgresql block should be in the same block as the drizzle block" do
          @postgresql_section.blocks.size.should == 2
          @postgresql_section.blocks.should include(@drizzle_block)
        end
      end

      describe "should break sections into slices to avoid overlaps:" do
        it "The section containing postgresql should contain a slice for postgresql and a slice for drizzle" do
          @postgresql_section.slices.size.should == 2
          @postgresql_section.slices.should include(@postgresql_slice)
          @postgresql_section.slices.should include(@drizzle_slice)
        end

        it "The rakudo section should contain a single slice" do
          @rakudo_section.slices.size.should == 1
        end
      end
    end
  end

  describe "(given an invalid set of items to process)" do
    it "should raise an error when given an item that is not scheduleable"
  end
end

class SchedulableThingy
  include Schedulable
end

describe SchedulableThingy do
  before(:each) do
    @thingy = SchedulableThingy.new
    @duration = 45
    @time1 = Time.now
    @time2 = @time1 + @duration.minutes
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
