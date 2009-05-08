class Schedule
  attr_accessor :days
  attr_accessor :sections
  attr_accessor :slices
  attr_accessor :blocks
  attr_accessor :items

  def initialize(event_or_items)
    case event_or_items
    when Event
      # FIXME Add support for initalizing Schedule from an Event
      raise NotImplementedError
    when Array
      self.items = event_or_items
    else
      raise TypeError, "Unknown type: #{event_or_items.class.name}"
    end
  end
end

module Schedulable
  def self.included(mixee)
    mixee.class_eval do
      attr_accessor :start_time
      attr_accessor :end_time
      attr_accessor :duration

      def end_time=(value)
        raise ArgumentError, "End time cannot be set without a start time" unless @start_time
        raise ArgumentError, "End time cannot be before start time" if value < @start_time
        @end_time = value
        @duration = @end_time - @start_time
      end

      def duration=(value)
        raise ArgumentError, "End time cannot be set without a start time" unless @start_time
        raise ArgumentError, "Duration cannot be negative" if value < 0
        @duration = value
        @end_time = @start_time + value
      end
    end
  end
end

class ScheduleDay
end

class ScheduleSection
  include Schedulable
end

class ScheduleSlice
  include Schedulable

end

class ScheduleBlock
  include Schedulable
end

class ScheduleItem
  include Schedulable
  # FIXME implement
end
