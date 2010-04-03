Factory.define :proposal_user do |f|
  # :belongs_to associations
  f.association :proposal
  f.association :user
end
