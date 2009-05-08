=begin
RAILS_ENV=test rake spec:db:fixtures:load
./script/console test
reload!; load 'schedule_demo.rb'
RAILS_ENV=test ./script/runner schedule_demo.rb
=end

event = Event.find(2009)
puts "* Event ##{event.id}: #{event.title}"
$schedule = Schedule.new(event)
for item in $schedule.items
  puts "* Item ##{item.id}: #{item.title} -- #{item.start_time.to_s(:db)} to #{item.end_time.to_s(:db)}"
end
for day in $schedule.days
  puts "* Day: #{day.date.to_s}"
  for section in day.sections
    puts "  * Section: #{section.start_time.to_s(:db)} to #{section.end_time.to_s(:db)}"
    for item in section.items
      puts "    * Item ##{item.id}: #{item.title} -- #{item.start_time.to_s(:db)} to #{item.end_time.to_s(:db)}"
    end
  end
end
require 'rubygems'; require 'ruby-debug'; Debugger.start; debugger; 1 # FIXME
