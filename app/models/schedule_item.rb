# == Schema Information
# Schema version: 20090616061006
#
# Table name: schedule_items
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)     
#  excerpt     :text            
#  description :text            
#  start_time  :datetime        
#  duration    :integer(4)      
#  event_id    :integer(4)      
#  room_id     :integer(4)      
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
