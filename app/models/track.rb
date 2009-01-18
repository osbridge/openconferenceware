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
end
