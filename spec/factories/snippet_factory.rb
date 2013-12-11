FactoryGirl.define do
  factory :snippet, class: OpenConferenceWare::Snippet do
    sequence(:slug){|n| "test-snippet-#{n}"}
    description "A testing snippet"
    content "This is only a test."
  end
end
