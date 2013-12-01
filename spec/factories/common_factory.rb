FactoryGirl.define do
  sequence(:email) { |n| "user#{n}@provider.com" }
  sequence(:website) { |n| "http://provider.com/~user#{n}" }
end
