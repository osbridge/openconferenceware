Factory.define :user do |f|
  f.sequence(:login) { |n| "user#{n}" }
  f.email { Factory.next(:email) }
  f.admin false
  f.remember_token nil
  f.remember_token_expires_at nil
  f.using_openid true
  f.affiliation "My affiliation"
  f.biography "My biography"
  f.website { Factory.next(:website) }
  f.complete_profile true
  f.sequence(:first_name) { |n| "user_first_name-#{n}" }
  f.sequence(:last_name) { |n|  "user_last_name-#{n}" }
  f.blog_url { Factory.next(:website) }
  f.identica { |record| record.fullname.gsub(/[^\w]/, '_').downcase }
  f.twitter { |record| record.fullname.gsub(/[^\w]/, '_').downcase }
end

Factory.define :admin, :parent => :user do |f|
  f.admin true
end
