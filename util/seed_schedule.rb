# Generate a weighted random schedule with any unscheduled talks
# (I pre-scheduled all of the long form talks, and excluded their time slots from the available slots here)

def seed_schedule
  e = OpenConferenceWare::Event.find_by_slug("2014")

  slots = []
  slots << [10.hours, 11.hours, 13.hours + 30.minutes, 14.hours + 30.minutes, 15.hours + 45.minutes, 16.hours + 45.minutes].map{|offset| e.dates[0] + offset}
  slots << [13.hours + 30.minutes, 14.hours + 30.minutes, 15.hours + 45.minutes, 16.hours + 45.minutes].map{|offset| e.dates[1] + offset}
  slots << [10.hours, 11.hours, 13.hours + 30.minutes, 14.hours + 30.minutes, 15.hours + 45.minutes, 16.hours + 45.minutes].map{|offset| e.dates[2] + offset}
  slots.flatten!

  schedule_hash = {}

  track_arrays = e.tracks.map { |track| track.proposals.accepted.where("start_time IS NULL").to_a.shuffle }

  slots.each do |slot|
    schedule_hash[slot] = []
    track_arrays.each do |track|
      schedule_hash[slot] << track.pop
      schedule_hash[slot].compact!
    end
  end

  remaining_sessions = track_arrays.flatten.shuffle

  schedule_hash.each do |slot, sessions|
    while sessions.count < 6 && remaining_sessions.count > 0
      sessions << remaining_sessions.pop
    end
  end

  slots.each do |slot|
    puts slot
    schedule_hash[slot].each do |session|
      puts "  - #{session.id}: #{session.title}"
    end
    puts "-"*80
  end

  puts "="*80
  puts "Remaining sessions"
  remaining_sessions.each do |session|
    puts "  - #{session.id}: #{session.title}"
  end

  puts "Save this schedule? y/n"
  response = gets

  if response.strip == "y"
    slots.each do |slot|
      puts slot
      schedule_hash[slot].each do |session|
        session.start_time = slot
        session.save!
      end
    end
  end
end

seed_schedule()
