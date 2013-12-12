FactoryGirl.define do
  factory :user, class: OpenConferenceWare::User do
    sequence(:first_name) {|n| "user_first_name-#{n}" }
    sequence(:last_name)  {|n| "user_last_name-#{n}" }
    affiliation "My affiliation"
    email
    website
    blog_url { generate(:website) }
    biography "My biography"
    complete_profile true
    identica { |record| record.fullname.gsub(/[^\w]/, '_').downcase }
    twitter { |record| record.fullname.gsub(/[^\w]/, '_').downcase }

    factory :admin do
      admin true
    end

    factory :selector do
      selector true
    end
  end
end
