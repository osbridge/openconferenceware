require 'spec_helper'

describe Schedule do
  fixtures :all

  before(:each) do
    # Sessions
    @sessions = []

    # ...typical session
    @sessions << @rakudo_session     = proposals(:rakudo_session)

    # ...at same time, but with different duration
    @sessions << @drizzle_session    = proposals(:drizzle_session)
    @sessions << @postgresql_session = proposals(:postgresql_session)

    # ..at same time, with same duration
    @sessions << @cloud_session      = proposals(:cloud_session)
    @sessions << @business_session   = proposals(:business_session)


    # Schedule items
    @schedule_items = []

    # ...without a duration/end_time
    @schedule_items << @opening_item = schedule_items(:opening)

    # ...with a duration/end_time
    @schedule_items << @coffee_break_item = schedule_items(:coffee_break)

    # ..without a start_time
    @schedule_items << @unscheduled_item = schedule_items(:unscheduled)

    # Composites
    @entries = (@sessions + @schedule_items).sort { rand }
    @scheduleable_entries = @entries - [@unscheduled_item]
    @schedule = Schedule.new(@entries)
  end

  it "should not initialize from unknown types" do
    lambda { Schedule.new(:omg) }.should raise_error(TypeError)
  end

  it "should initialize from an Event" do
    @schedule.days.should_not be_empty
    @schedule.sections.should_not be_empty
    @schedule.slices.should_not be_empty
    @schedule.blocks.should_not be_empty
    @schedule.items.should_not be_empty
  end

  it "should sort schedule contents by their start time and end time if given" do
    @schedule.items.should == @schedule.items.sort_by{|t| [t.start_time.to_i, t.end_time.to_i]}
  end

  it "should initialize from an array of proposals, skipping unscheduled items" do
    @schedule.items.sort_by(&:title).should == @scheduleable_entries.sort_by(&:title)
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

        @postgresql_block = @blocks.find{|block| block.items.include?(@postgresql_session)}
        @drizzle_block = @blocks.find{|block| block.items.include?(@drizzle_session)}
        @rakudo_block = @blocks.find{|block| block.items.include?(@rakudo_session)}
        @cloud_block = @blocks.find{|block| block.items.include?(@cloud_session)}

        @postgresql_slice = @slices.find{|slice| slice.blocks.include?(@postgresql_block)}
        @drizzle_slice = @slices.find{|slice| slice.blocks.include?(@drizzle_block)}

        @rakudo_section = @sections.find{|section| section.blocks.include?(@rakudo_block)}
        @postgresql_section = @sections.find{|section| section.blocks.include?(@postgresql_block)}
      end

      it "should create a day for each day represented in the input set" do
        @days.map(&:date).sort.should == @scheduleable_entries.map{|entry| entry.start_time.to_date}.uniq.sort
      end

      it "each item should be contained in one and only one block" do
        @scheduleable_entries.each do |entry|
          @blocks.select{|block| block.items.include?(entry)}.size.should == 1
        end
      end

      it "should set the time boundries for each block equal to those of its items" do
        @blocks.each do |block|
          block.items.each do |item|
            block.start_time.should == item.start_time
            block.duration.to_i.should == item.duration.to_i
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

  describe "with conflicts" do
    before(:each) do
      @time1 = Time.zone.parse("2009-05-13 18:00")
      @time2 = Time.zone.parse("2009-05-13 20:45")
      @time3 = Time.zone.parse("2009-05-13 21:00")
      @time4 = Time.zone.parse("2009-05-13 21:30")

      @room1 = stub_model(Room)
      @room2 = stub_model(Room)

      @user1 = stub_model(User)
      @user2 = stub_model(User)

      # Same time and room
      @item1 = stub_model(Proposal, :room => @room1, :start_time => @time1, :end_time => @time2)
      @item2 = stub_model(Proposal, :room => @room1, :start_time => @time1, :end_time => @time2)

      # Same time, different room
      @item3 = stub_model(Proposal, :room => @room2, :start_time => @time1, :end_time => @time2)

      # Different time, same room
      @item4 = stub_model(Proposal, :room => @room1, :start_time => @time3, :end_time => @time4)

      # Same time and speaker
      @item5 = stub_model(Proposal, :room => @room1, :start_time => @time1, :end_time => @time2, :users => [@user1])
      @item6 = stub_model(Proposal, :room => @room2, :start_time => @time1, :end_time => @time2, :users => [@user1])

      # Same time, different speaker
      @item7 = stub_model(Proposal, :room => @room2, :start_time => @time1, :end_time => @time2, :users => [@user2])

      # Different time and speaker
      @item8 = stub_model(Proposal, :room => @room2, :start_time => @time3, :end_time => @time4, :users => [@user2])

      # User associations
      @user1.stub!(:proposals).and_return(mock(Array, :scheduled => mock(Array, :all => [@item5, @item6])))
      @user2.stub!(:proposals).and_return(mock(Array, :scheduled => mock(Array, :all => [@item7, @item8])))
    end

    describe "for users" do
      it "should identify conflicting items" do
        items = [@item5, @item6]
        schedule = Schedule.new(items)
        conflicts = schedule.user_conflicts
        conflicts.size.should == 1
      end

      it "should not misidentify nonconflicting items" do
        items = [@item5, @item7]
        schedule = Schedule.new(items)
        conflicts = schedule.user_conflicts
        conflicts.size.should == 0
      end
    end

    describe "for rooms" do
      it "should identify items happening at same time and room" do
        schedule = Schedule.new([@item1, @item2])
        conflicts = schedule.room_conflicts
        conflicts.size.should == 1
        [
          {:room => @room1, :item => @item1, :conflicts_with => @item2},
          {:room => @room1, :item => @item2, :conflicts_with => @item1}
        ].should include(conflicts.first)
      end

      it "should not identify items happening at same time in separate rooms" do
        schedule = Schedule.new([@item1, @item3])
        conflicts = schedule.room_conflicts
        conflicts.size.should == 0
      end

      it "should not identify items happening at different times in same room" do
        schedule = Schedule.new([@item1, @item4])
        conflicts = schedule.room_conflicts
        conflicts.size.should == 0
      end
    end
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

describe ScheduleDay do
  it "should compute lowest-common multiplier for day's section slices" do
    values = [5, 6, 15]
    day = ScheduleDay.new([])
    day.stub!(:sections).and_return(mock(Array, :map => values))
    day.lcm_colspan.should == 30
  end
end

describe ScheduleSection do
  it "should compute least-common multiplier for section's slice blocks" do
    values = [3, 4, 6]
    section = ScheduleSection.new([])
    section.stub!(:slices).and_return(mock(Array, :map => values))
    section.lcm_rowspan.should == 12
  end
end
