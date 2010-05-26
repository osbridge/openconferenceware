Factory.define :room do |f|
  f.sequence(:name) { |n| "Room #{n}" }
  f.capacity 40
  f.size "12 x 20 feet"
  f.seating_configuration "Theater"

  # :belongs_to association
  # * :event
end
