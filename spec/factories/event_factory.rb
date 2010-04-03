Factory.define :event do |f|
  f.sequence(:title) { |n| "Event #{n}" }
  f.deadline { Date.today.to_time + 1.day }
  f.open_text "We're accepting proposals"
  f.closed_text "We're not accepting proposals"
  f.proposal_status_published false
  f.session_text "We have sessions"
  f.tracks_text "We have tracks"
  f.start_date { Date.today.to_time + 2.days }
  f.end_date { Date.today.to_time + 3.days }
  f.accept_proposal_comments_after_deadline false
  f.slug { |record| record.title.downcase.gsub(/[^\w]/, '') }
  f.schedule_published false
  f.parent_id nil
  f.proposal_titles_locked false

  # :has_many associations
  f.tracks { |record| [record.association(:track, :event => record.result)] }
  f.rooms { |record| [record.association(:room, :event => record.result)] }
  f.session_types { |record| [record.association(:session_type, :event => record.result)] }
end
