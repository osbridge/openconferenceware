Factory.define :session_type do |f|
  f.sequence(:title) { |n| "Session Type #{n}" }
  f.description { |record| "#{record.title} description" }
  f.duration "45"

  # :belongs_to association
  f.association :event
end
