FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    deadline { Date.today.to_time + 1.day }
    open_text "We're accepting proposals"
    closed_text "We're not accepting proposals"
    proposal_status_published false
    session_text "We have sessions"
    tracks_text "We have tracks"
    start_date { Date.today.to_time + 2.days }
    end_date { Date.today.to_time + 3.days }
    accept_proposal_comments_after_deadline false
    slug { |record| record.title.downcase.gsub(/[^\w]/, '') }
    schedule_published false
    parent_id nil
    proposal_titles_locked false

    factory :populated_event do
      after(:create) do |record, evaluator|
        record.rooms         << create(:room,         event: record) if record.rooms.empty?
        record.tracks        << create(:track,        event: record) if record.tracks.empty?
        record.session_types << create(:session_type, event: record) if record.session_types.empty?
      end
    end
  end
end
