FactoryGirl.define do
  factory :room, class: OpenConferenceWare::Room do
    sequence(:name) { |n| "Room #{n}" }
    capacity 40
    size "12 x 20 feet"
    seating_configuration "Theater"

    # :belongs_to association
    # * :event
  end
end
