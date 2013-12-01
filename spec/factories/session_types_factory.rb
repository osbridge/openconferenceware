FactoryGirl.define do
  factory :session_type do
    sequence(:title) { |n| "Session Type #{n}" }
    description { |record| "#{record.title} description" }
    duration "45"

    # :belongs_to association
    # * :event
  end
end
