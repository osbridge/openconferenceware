FactoryGirl.define do
  factory :schedule_item do
    sequence(:title) { |n| "ScheduleItem #{n}" }
    excerpt "My schedule item description"
    description "My schedule item description"
    start_time { Time.now }
    duration   45

    # :belongs_to associations:
    # * :event
    # * :room
  end
end
