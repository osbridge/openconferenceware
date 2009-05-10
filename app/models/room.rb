# == Schema Information
# Schema version: 20090510024259
#
# Table name: rooms
#
#  id                    :integer         not null, primary key
#  name                  :string(255)     not null
#  capacity              :integer         
#  size                  :string(255)     
#  seating_configuration :string(255)     
#  description           :text            
#  event_id              :integer         
#  created_at            :datetime        
#  updated_at            :datetime        
#

class Room < ActiveRecord::Base
  # Associations
  belongs_to :event
  has_many :proposals
  has_many :schedule_items

  # Validations
  validates_presence_of :name, :event
  validates_numericality_of :capacity, :unless => lambda{|obj| obj.capacity.blank? }
end
