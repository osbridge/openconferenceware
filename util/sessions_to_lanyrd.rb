# Hackily adds all session of an event on Lanyrd

YEAR = 2013
LANYRD_EVENT = "http://lanyrd.com/#{YEAR}/osbridge"
CREDENTIALS = YAML.load(File.read('credentials.yml'))
# credentials.yml should contain two keys: username and password

event = Event.find_by_slug(YEAR.to_s)
agent = Mechanize.new
existing_sessions = []
existing_schedule_items = []

# Sign in using the twitter account specified in credentials.yml
puts "Signing in as #{CREDENTIALS[:username]}…"
page = agent.get('http://lanyrd.com/twitter/signin')
twitter_form = page.forms.first
twitter_form["session[username_or_email]"] = CREDENTIALS[:username]
twitter_form["session[password]"] = CREDENTIALS[:password]
page = agent.submit(twitter_form, twitter_form.buttons.first)

continue_link = agent.page.links.find{|l| l.text == "click here to continue"}
page = continue_link.click if continue_link

# Grab the lanyrd schedule page for the event and iterate through existing sessions
puts "Fetching schedule page"
schedule_page_url = "#{LANYRD_EVENT}/schedule"
schedule_page = agent.get(schedule_page_url)

if schedule_page.search(".pagination").count > 0
  session_links = []

  last_page = schedule_page.search(".pagination a").last.text.to_i

  1.upto(last_page) do |page|
    puts "  - Multi-page schedule, fetching page #{page}"
    day_schedule_page = agent.get("#{schedule_page_url}?page=#{page}")
    session_links << day_schedule_page.links.select{|l| l.node.parent.name == 'h2' && l.node.parent.parent.attr(:class).to_s.include?("schedule-item")}
  end
  session_links.flatten!
else
  session_links = schedule_page.links.select{|l| l.node.parent.name == 'h2' && l.node.parent.parent.attr(:class).to_s.include?("schedule-item")}
end

session_links.each_with_index do |link, index|
  puts "Fetching session #{index+1} of #{session_links.count}: #{link.text}"
  session_page = link.click

  # If there's a link to the "official session page", use that to find an OCW session ID and load the session
  osb_session_page_header = session_page.root.css('.session-meta-item h3').find{|h3| h3.text == "Official session page"}
  osb_session_page_link = osb_session_page_header && osb_session_page_header.parent.css('a').first

  if osb_session_page_link
    osb_type = osb_session_page_link.attr('href').split('/')[-2]
    osb_id = osb_session_page_link.attr('href').split('/').last
    if osb_type == 'sessions'
      existing_sessions << osb_id
      session = Proposal.find(osb_id.to_i)
      if session
        # Add OCW tags as lanyrd topics. We're only allowed five topics on laynrd.
        unless session.tags.blank?
          existing_topics = session_page.root.css('ul.tags li').map{|t| t.text.strip.downcase.gsub(' ','')}
          puts "  - Existing topics: #{existing_topics.join(', ')}"
          if existing_topics.size < 5
            session.tags[0..6].each do |tag|
              next if existing_topics.size == 5 || existing_topics.include?(tag.to_s.downcase.strip.gsub(' ',''))
              puts "    - Adding topic: #{tag}"
              topic_search_page = agent.get(session_page.uri.to_s + "topics/?q=#{tag}")
              add_topic_form = topic_search_page.forms.find{|f| f.buttons.map{|b| b.value}.include?("Add this topic")}
              if add_topic_form
                add_topic_form.submit(add_topic_form.buttons.last)
              end
            end
          end
        end

        current_coverage = session_page.root.css('#coverage .coverage-item h3 a').map{|a| a.attr('href')}
        coverage_form = session_page.forms.find{|f| f.form_node.attr('id') == 'add-coverage'}

        # Add session audio link
        if !session.audio_url.blank? && !current_coverage.include?(session.audio_url)
          puts "  - Adding session audio"
          coverage_form.url = session.audio_url
          coverage_details_page = coverage_form.submit
          while coverage_details_page.title.include?('Working')
            coverage_details_page = agent.get(coverage_details_page.uri)
          end

          coverage_details_form = coverage_details_page.forms.find{|f| f.action.include?('add-link')}
          coverage_details_form.title = "Session Audio"
          coverage_details_form.radiobuttons_with(name: 'type').find{|r| r.value == '2'}.check
          session_page = coverage_details_form.submit
          coverage_form = session_page.forms.find{|f| f.form_node.attr('id') == 'add-coverage'}
        end

        # Add session notes wiki link
        # SKIP session notes for 2011 at the moment…
        if session.start_time < Time.now && !session.session_notes_url.blank? && !current_coverage.any?{|c| c.include?("http://opensourcebridge.org/#{YEAR}/wiki/")}
          puts "  - Adding session notes: #{session.session_notes_url}"
          coverage_form.url = session.session_notes_url
          coverage_details_page = coverage_form.submit
          while coverage_details_page.title.include?('Working')
            coverage_details_page = agent.get(coverage_details_page.uri)
          end

          coverage_details_form = coverage_details_page.forms.find{|f| f.action.include?('add-link')}
          coverage_details_form.radiobuttons_with(name: 'type').find{|r| r.value == '6'}.check
          session_page = coverage_details_form.submit
        end
      end
    elsif osb_type == 'schedule_items'
      existing_schedule_items << osb_id
    end
  end
end

# Add sessions that aren't already on Lanyrd
sessions_and_schedule_items = event.proposals.confirmed + event.schedule_items

sessions_and_schedule_items.each do |session|
  next if (session.is_a?(Proposal) && existing_sessions.include?(session.id.to_s)) || (session.is_a?(ScheduleItem) && existing_schedule_items.include?(session.id.to_s))
  puts "Adding '#{session.title}'"
  
  new_session_page = agent.get("http://lanyrd.com/#{YEAR}/osbridge/add-session/")
  new_session_form = new_session_page.forms.last
  new_session_form.title = session.title
  new_session_form.abstract = session.description
  if session.is_a?(Proposal)
    new_session_form.url = "http://opensourcebridge.org/sessions/#{session.id}"
  elsif session.is_a?(ScheduleItem)
    new_session_form.url = "http://opensourcebridge.org/events/#{YEAR}/schedule_items/#{session.id}"
  end
  new_session_form.start_datetimefull = session.start_time.strftime("%Y-%m-%d %H:%M")
  new_session_form.end_datetimefull = session.end_time.strftime("%Y-%m-%d %H:%M")

  speakers_page = agent.submit(new_session_form, new_session_form.buttons.first)
  new_session_id = speakers_page.uri.to_s.split('/')[-1]

  user_search_base = "http://lanyrd.com/#{YEAR}/osbridge/edit/schedule/?action=speaker_search&row_id=#{new_session_id}&q="
  
  if session.is_a?(Proposal)
    session.users.each do |user|
      puts "  - Adding speaker: #{user.fullname} (@#{user.twitter.to_s.gsub('@','').strip.downcase})"
      added = false
      if !user.twitter.blank?
        user_search_page = agent.get(user_search_base + user.twitter.to_s.gsub('@','').strip.downcase)
        matching_add_user_form = user_search_page.forms.select{|f| f.form_node.parent.search(".handle").first && f.form_node.parent.search(".handle").first.text.strip == "@#{user.normalized_twitter}"}.first

        if matching_add_user_form
          puts "    …found exact twitter match for user, adding"
          added_twitter_user = matching_add_user_form.submit
          added = true
        end
      end

      unless added
        user_add_page = agent.get("http://lanyrd.com/#{YEAR}/osbridge/edit/schedule/?action=add_name&name=#{user.fullname}&row_id=#{new_session_id}")
        puts "    …adding as an unlinked user"

        added_unlinked_user = user_add_page.form_with(action: "http://lanyrd.com/#{YEAR}/osbridge/edit/schedule/") do |f|
          f.name = user.fullname
          f.role = user.affiliation
        end.submit
      end
    end
  end
end
