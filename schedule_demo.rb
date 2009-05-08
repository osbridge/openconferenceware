# This script exercises Schedule. Run the following commands to use it:
=begin
RAILS_ENV=test rake spec:db:fixtures:load
RAILS_ENV=test ./script/runner schedule_demo.rb
=end

event = Event.find(2009)
puts "* Event: #{event.title}"
$schedule = Schedule.new(event)
for item in $schedule.items
  puts "  - EventItem: #{item.title} -- #{item.start_time.to_s(:db)} to #{item.end_time.to_s(:db)}"
end
for day in $schedule.days
  puts "  * Day: #{day.date.to_s}"
  for item in day.items
    puts "    - DayItem: #{item.title} -- #{item.start_time.to_s(:time)} to #{item.end_time.to_s(:time)}"
  end
  for section in day.sections
    puts "    * Section: #{section.start_time.to_s(:time)} to #{section.end_time.to_s(:time)}"
    for item in section.items
      puts "      - SectionItem: #{item.title} -- #{item.start_time.to_s(:time)} to #{item.end_time.to_s(:time)}"
    end
    for slice in section.slices
      puts "      * Slice: #{section.start_time.to_s(:time)} to #{section.end_time.to_s(:time)}"
      for item in slice.items
        puts "        - SliceItem: #{item.title} -- #{item.start_time.to_s(:time)} to #{item.end_time.to_s(:time)}"
      end
      for block in slice.blocks
        puts "        * Block: #{block.start_time.to_s(:time)} to #{block.end_time.to_s(:time)}"
        for item in block.items
          puts "          - BlockItem: #{item.title} -- #{item.start_time.to_s(:time)} to #{item.end_time.to_s(:time)}"
        end
      end
    end
  end
end
