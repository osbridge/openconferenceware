# == Schema Information
# Schema version: 20090608053232
#
# Table name: rooms
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)     not null
#  capacity              :integer(4)      
#  size                  :string(255)     
#  seating_configuration :string(255)     
#  description           :text            
#  event_id              :integer(4)      
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

  # Image Attachment
  has_attached_file :image,
    :styles => {
      :large => "650>",
      :medium => "350>",
      :small => "150>"
    }
end
