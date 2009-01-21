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
