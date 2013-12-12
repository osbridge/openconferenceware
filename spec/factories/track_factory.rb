FactoryGirl.define do
  factory :track, class: OpenConferenceWare::Track do
    sequence(:title) { |n| "Track #{n}" }
    description { |record| "#{record.title} description" }
    color "#000000"
    excerpt "A track"
    association :event

    # :belongs_to association
    # * :event
  end
end
