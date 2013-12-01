FactoryGirl.define do
  factory :snippet do
    sequence(:slug){|n| "test-snippet-#{n}"}
    description "A testing snippet"
    content "This is only a test."
  end
end
