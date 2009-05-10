class ScheduleItem < ActiveRecord::Base
  belongs_to :event
  belongs_to :room

  # Provides #overlaps?
  include ScheduleOverlapsMixin

  # Return the time this session ends.
  def end_time
    self.start_time + (self.duration || 0).minutes
  end
end
