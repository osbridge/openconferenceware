# == Schema Information
# Schema version: 20090121212823
#
# Table name: tracks
#
#  id          :integer         not null, primary key
#  title       :string(255)     
#  description :string(255)     
#  color       :string(255)     
#  event_id    :integer         
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Track < ActiveRecord::Base
  # Associations
  belongs_to :event
  has_many :proposals

  # Validations
  validates_presence_of \
    :color,
    :description,
    :event_id,
    :title
    
  def <=>(against)
    self.title <=> (against.nil? ? '' : against.title)
  end
end
