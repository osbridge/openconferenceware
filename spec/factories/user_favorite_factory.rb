Factory.define :user_favorite do |f|
  f.association :user
  f.association :proposal
end