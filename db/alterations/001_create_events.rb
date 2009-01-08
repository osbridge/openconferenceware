require 'time'
require 'date'

ip2 = Event.new(
  :title => "Ignite Portland 2",
  :deadline => Time.parse("2008/02/05"),
  :open_text => "Deadline for proposals has passed.",
  :closed_text => <<-HERE
Ignite Portland 2 is coming on Tuesday, February 5. Visit <a href="http://www.igniteportland.com">Ignite Portland</a> for more information about the event.
<br />
<br />
The submission deadline has passed and we are not accepting any new proposals for this event. The selection committee has begun choosing presentations and will announce their decision soon. We thank all those that submitted proposals and helped spread word of the event.
  HERE
)
ip2.id = 2
ip2.save!

ip3 = Event.new(
  :title => "Ignite Portland 3",
  :deadline => Time.parse("2008/03/28"),
  :open_text => "Deadline for proposals has passed.",
  :closed_text => <<-HERE
Ignite Portland 3 is coming on Wednesday, June 18th, 2008. Visit <a href="http://www.igniteportland.com">Ignite Portland</a> for more information about the event.
<br />
<br />
The submission deadline has passed and we are not accepting any new proposals for this event. The selection committee has begun choosing presentations and will announce their decision soon. We thank all those that submitted proposals and helped spread word of the event.
  HERE
)
ip3.id = 3
ip3.save!

ip4 = Event.new(
  :title => "Ignite Portland 4",
  :deadline => Time.parse("2008/11/13"),
  :open_text => <<-HERE,
Ignite Portland 4 is coming on November 13, 2008. Visit <a href="http://www.igniteportland.com">Ignite Portland</a> for more information about the event.
<br />
<br />
If you had five minutes to talk to Portland what would you say? What if you only got 20 slides and they rotated automatically after 15 seconds? Launch a web site? Teach a hack? Talk about recent learnings, successes, failures? Fill out the form below to submit your talk. We are looking for talks that will inspire and teach, not recruiting or product pitches.
  HERE
  :closed_text => <<-HERE
Ignite Portland 4 is coming on November 13, 2008. Visit <a href="http://www.igniteportland.com">Ignite Portland</a> for more information about the event.
<br />
<br />
The submission deadline has passed and we are not accepting any new proposals for this event. The selection committee has begun choosing presentations and will announce their decision soon. We thank all those that submitted proposals and helped spread word of the event.
  HERE
)
ip4.id = 4
ip4.save!
