# Prepare
event = OpenConferenceWare::Event.find_by_slug '2014'
proposals = event.proposals.accepted

# Setup data structures
proposal_id_pairs_with_shared_favorites = proposals.inject([]) {|s,a| proposals.each {|b| s << [a.id, b.id, (a.user_favorites.map(&:user_id) & b.user_favorites.map(&:user_id)).length] }; s}
proposal_ids_and_start_times = proposals.map{|o| [o.id, o.start_time.to_i]}
proposals_by_start_times = proposals.group_by{|o| o.start_time.to_i}

# Analyze contention
proposals_by_start_times_with_contention = {}
proposals_by_start_times.keys.each do |start_time|
  proposals_by_start_times_with_contention[start_time] ||= []
  proposals_for_start_time = proposals_by_start_times[start_time].sort_by(&:id)
  proposals_for_start_time.each do |a|
      proposals_for_start_time.each do |b|
        next if a.id >= b.id
        proposals_by_start_times_with_contention[start_time] << [a, b, (a.user_favorites.map(&:user_id) & b.user_favorites.map(&:user_id)).length]
      end
  end
  proposals_by_start_times_with_contention[start_time] =
    proposals_by_start_times_with_contention[start_time].sort_by{|t| - t[2]}
end

# Produce report
puts <<-HERE
SCHEDULE CONTENTION REPORT
==========================

Listing of schedule time slots with proposals and ther number of shared
user favorites. If time slot has no entries, there's no contention. The
more shared favorites between two proposals, the worse the contention
between them:

HERE
proposals_by_start_times_with_contention.keys.sort.each do |start_time|
  puts "* %s" % [start_time == 0 ? "Sessions without a time assigned" : Time.zone.at(start_time).inspect]
  proposals_by_start_times_with_contention[start_time].each do |a,b,contention|
    next if contention == 0
    puts "- %d favorites on #%d (%s) and #%d (%s)" % [contention, a.id, a.title, b.id, b.title]
  end
end
