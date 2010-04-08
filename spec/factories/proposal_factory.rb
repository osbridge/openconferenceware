# NOTE: A proposal's relationship to it's user profile information is
# configurable. If `SETTINGS.have_user_profiles` is false, then the proposal
# contains the user profile information (e.g., presenter's name). However,
# if false, the proposal has many users that each have their own profile as
# part of their user record.
Factory.define :proposal do |f|
  f.user_id nil
  f.presenter "Presenter name"
  f.affiliation "My affiliation"
  f.email { Factory.next(:email) }
  f.website { Factory.next(:website) }
  f.biography "My biography"
  f.sequence(:title) { |n| "Proposal #{n}" }
  f.description "My proposal description"
  f.agreement true
  f.note_to_organizers "My note to organizers"
  f.excerpt "My excerpt"
  f.status "proposed"
  f.start_time nil

  # :belongs_to associations
  f.association :event
  f.association :track
  f.association :session_type
  f.association :room
end
