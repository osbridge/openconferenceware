# Assigns rooms, based on user_favorite popularily
#
# Usage: rails runner assign_rooms.rb

class RoomAllocator
  LARGE_ROOMS = ["B202/203", "B302/303"]
  SMALL_ROOMS = ["B201", "B204", "B301", "B304"]

  def initialize
    @current_event = OpenConferenceWare::Event.current
    @sessions = @current_event.proposals.confirmed.scheduled.sort_by{|s| s.user_favorites.count }.reverse
    @rooms = (LARGE_ROOMS + SMALL_ROOMS).map{|rn| @current_event.rooms.find_by_name(rn) }
  end

  def room_available_at?(room, start_time)
    @sessions.select{|s| s.start_time == start_time}.all?{|s| s.room != room}
  end

  def allocate_rooms
    @sessions.each do |session|
      next if session.room.present?
      first_available_room = @rooms.find{|room| room_available_at?(room, session.start_time)}
      if first_available_room.present?
        puts "[#{session.user_favorites.count}] Assigned #{session.title} to #{first_available_room.name}"
        session.room = first_available_room
      else
        puts "[!!] Could not find a room assignment for #{session.title}"
      end
    end

    puts "---"
    puts "Accept room assignments? (y/n)"
    if gets.chomp == "y"
      @sessions.each{|s| s.save!}
    end
  end
end


RoomAllocator.new.allocate_rooms
