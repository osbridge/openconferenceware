# Transfer schedule_items from previous year

def transfer_schedule_items
  current = Event.current
  past = Event.find_by_slug('2012')

  Event.current.dates.each_with_index do |day, i|
    past_date = past.dates[i]
    offset = (day - past_date).days

    past.schedule_items.select{|s| s.start_time.to_date == past_date}.each do |past_schedule_item|
      new_attributes = past_schedule_item.attributes
      new_attributes.delete("created_at")
      new_attributes.delete("updated_at")
      new_attributes.delete("id")
      new_attributes.delete("room_id")
      new_attributes["start_time"] += offset
      new_schedule_item = current.schedule_items.new(new_attributes)
      puts "#{new_schedule_item.start_time}: #{new_schedule_item.title}"
      new_schedule_item.save
    end
  end
end

transfer_schedule_items()
