module OpenConferenceWare
  class Schedule
    attr_accessor :items
    attr_accessor :is_admin

    def initialize(event_or_items, is_admin=false)
      self.items = []
      self.is_admin = is_admin

      case event_or_items
      when Event
        self.items = event_or_items.calendar_items(is_admin)
      when Array
        self.items = event_or_items
      else
        raise TypeError, "Unknown type: #{event_or_items.class.name}"
      end
      self.items = self.items.select(&:start_time).sort_by{|t| [t.start_time.to_i, t.end_time.to_i]}
    end

    def days
      @days ||= ScheduleDay.new_array_from(items)
    end

    def sections
      @sections ||= self.days.map(&:sections).flatten
    end

    def slices
      @slices ||= self.sections.map(&:slices).flatten
    end

    def blocks
      @blocks ||= self.slices.map(&:blocks).flatten
    end

    def room_conflicts
      @room_conflicts ||= [].tap do |conflicts|
        self.items.select(&:room).group_by(&:room).each do |room, items|
          items.each do |item|
            if (conflicts_with = items.find{ |o| o.overlaps?(item) }) && conflicts_with != item
              conflicts << {
                room: room,
                item: item,
                conflicts_with: conflicts_with
              }
            end
          end
        end
      end
    end

    def user_conflicts
      @user_conflicts ||= [].tap do |conflicts|
        self.items.select{|item| item.respond_to?(:users)}.inject({}){|u2i, item| item.users.each{|user| u2i[user] ||= Set.new; u2i[user] << item}; u2i}.each do |user, items|
          items.each do |item|
            if (conflicts_with = items.find{ |o| o.overlaps?(item) }) && conflicts_with != item
              conflicts << {
                user: user,
                room: item.room,
                item: item,
                conflicts_with: conflicts_with
              }
            end
          end
        end
      end
    end
  end

  module Schedulable
    def self.included(mixee)
      mixee.class_eval do
        attr_accessor :start_time
        attr_accessor :end_time
        attr_accessor :duration

        include ScheduleOverlapsMixin

        def end_time=(value)
          raise ArgumentError, "End time cannot be set without a start time" unless @start_time
          raise ArgumentError, "End time cannot be before start time" if value < @start_time
          @end_time = value
          @duration = (@end_time - @start_time) / 1.minutes
        end

        def duration=(value)
          raise ArgumentError, "End time cannot be set without a start time" unless @start_time
          raise ArgumentError, "Duration cannot be negative" if value < 0
          @duration = value
          @end_time = @start_time + value.minutes
        end
      end
    end
  end

  class ScheduleDay
    attr_accessor :date
    attr_accessor :items

    def initialize(items=[], date=nil)
      self.items = items
      self.date = date
    end

    def self.new_array_from(items)
      [].tap do |days|
        items.group_by{|item| item.start_time.to_date}.each do |date, collection|
          days << self.new(collection, date)
        end
      end.sort_by(&:date)
    end

    def sections
      @sections ||= ScheduleSection.new_array_from(self.items)
    end

    def slices
      @slices ||= self.sections.map(&:slices).flatten
    end

    def blocks
      @blocks ||= self.slices.map(&:blocks).flatten
    end

    def lcm_colspan
      first, *rest = sections.map{ |section| section.slices.size }
      rest.inject(first) { |l, n| l.lcm(n) }
    end
  end

  class ScheduleSection
    include Schedulable
    attr_accessor :items

    def initialize(items=[], start_time=nil, end_time=nil)
      self.items = items
      self.start_time = start_time if start_time
      self.end_time = end_time if end_time
    end

    def self.new_array_from(items)
      [].tap do |sections|
        for item in items
          if section = sections.find{|section| section.overlaps?(item)}
            section.items << item
            section.start_time = item.start_time if section.start_time > item.start_time
            section.end_time = item.end_time if section.end_time < item.end_time
          else
            sections << self.new([item], item.start_time, item.end_time)
          end
        end
      end.sort_by{|section| [section.start_time, section.end_time, section.items.first.title]}
    end

    def slices
      @slices ||= ScheduleSlice.new_array_from(self.items)
    end

    def blocks
      @blocks ||= self.slices.map(&:blocks).flatten
    end

    def lcm_rowspan
      first, *rest = slices.map{ |slice| slice.blocks.size }
      rest.inject(first) { |l, n| l.lcm(n) }
    end
  end

  class ScheduleSlice
    include Schedulable
    attr_accessor :items
    attr_accessor :blocks

    def initialize(items=[], start_time=nil, end_time=nil, blocks=[])
      self.items = items
      self.start_time = start_time
      self.end_time = end_time
      self.blocks = blocks.empty? ? ScheduleBlock.new_array_from(self.items) : blocks
    end

    def self.new_array_from(items)
      [].tap do |slices|
        for block in ScheduleBlock.new_array_from(items)
          if slice = slices.find{|slice| ! slice.overlaps?(block)}
            slice.blocks << block
            slice.items += block.items
            slice.start_time = block.start_time if slice.start_time > block.start_time
            slice.end_time = block.end_time if slice.end_time < block.end_time
          else
            slices << self.new(block.items, block.start_time, block.end_time, [block])
          end
        end
      end.sort_by{|slice| [slice.start_time, slice.end_time, slice.items.first.title]}
    end
  end

  class ScheduleBlock
    include Schedulable
    attr_accessor :items

    def initialize(items=[], start_time=nil, end_time=nil)
      self.items = items.sort_by{|item| [item.start_time, item.end_time, (item.room.try(:name) || ""), item.title]}
      self.start_time = start_time
      self.end_time = end_time
    end

    def self.new_array_from(items)
      [].tap do |blocks|
        items.group_by{|item| [item.start_time, item.end_time]}.each do |range, collection|
          blocks << self.new(collection, range.first, range.last)
        end
      end.sort_by{|block| [block.start_time, block.end_time, block.items.first.title]}
    end
  end
end
