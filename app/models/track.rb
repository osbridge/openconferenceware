# == Schema Information
# Schema version: 20090616061006
#
# Table name: tracks
#
#  id          :integer(4)      not null, primary key
#  title       :string(255)     
#  description :text            
#  color       :string(255)     
#  event_id    :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#  excerpt     :text            
#

class Track < ActiveRecord::Base
  # Associations
  belongs_to :event
  has_many :proposals

  # Validations
  validates_presence_of \
    :color,
    :description,
    :excerpt,
    :event_id,
    :title
    
  def <=>(against)
    self.title <=> (against.nil? ? '' : against.title)
  end

  def color
    (stored_color = read_attribute(:color)).nil? ? nil : Color::RGB.from_html(stored_color)
  end

  def color=(value)
    case value
    when Color::RGB
      new_color = value
    when String
      new_color = Color::RGB.from_html(value)
    else
      raise TypeError
    end
    write_attribute(:color,new_color.html)
  end
end
