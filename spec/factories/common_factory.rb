Factory.sequence(:email) { |n| "user#{n}@provider.com" }

Factory.sequence(:website) { |n| "http://provider.com/~user#{n}" }
