# == Schema Information
# Schema version: 20090616061006
#
# Table name: session_types
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)     
#  description :text            
#  duration    :integer(4)      
#  event_id    :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class SessionType < ActiveRecord::Base
  # Associations
  belongs_to :event
  has_many :proposals

  # Validations
  validates_presence_of \
    :title,
    :description,
    :event_id

  def <=>(against)
    self.title <=> (against.nil? ? '' : against.title)
  end
end
