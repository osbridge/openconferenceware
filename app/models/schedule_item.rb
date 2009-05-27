# == Schema Information
# Schema version: 20090521012427
#
# Table name: schedule_items
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  excerpt     :string(255)
#  description :string(255)
#  start_time  :datetime
#  duration    :integer
#  event_id    :integer
#  room_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

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
