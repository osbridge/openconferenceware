Factory.define :schedule_item do |f|
  f.sequence(:title) { |n| "ScheduleItem #{n}" }
  f.excerpt "My schedule item description"
  f.description "My schedule item description"
  f.start_time { Time.now }
  f.duration   45

  # :belongs_to associations:
  # * :event
  # * :room
end
