namespace :bridgepdx do
  desc "Fetch common styles from github and install them in the local instance"
  task :styles do
    sh "rm -rf tmp/style_clone"
    sh "git clone --depth 1 git://github.com/reidab/osbp_styles.git tmp/style_clone"
    sh "rsync -uvax --exclude='.git' --exclude='Rakefile' --exclude='README.markdown' tmp/style_clone/ themes/bridgepdx/stylesheets/common_css/"
    sh "rm -rf tmp/style_clone"
  end

  desc "Export session information CSV for schedule monitor cards"
  task :session_card_csv => :environment do
    event = ENV['EVENT'].nil? ? Event.current : Event.find_by_slug(ENV['EVENT'])
    FasterCSV.open('session_cards.csv','w') do |csv|
      csv << %w(room start_time title speakers)
      event.proposals.confirmed(:order => 'start_time ASC').each do |session|
        row = []
        row << session.room.ergo.name
        row << session.start_time.strftime("%A, %B %d, %I:%M%p")
        row << session.title
        row << session.users.map{|u| u.fullname}.join(', ')
        csv << row
      end
    end
  end

  desc 'Symlink a checkout of the common styles at DIR to bridge theme'
  task 'styles:symlink' do
    unless ENV['DIR']
      puts <<-HERE
ERROR: You must specify a DIR environmental variable with the path to the checkout of your common styles. For example:
  rake bridgepdx:styles:symlink DIR=~/checkouts/osbp_styles
      HERE
      exit 1
    end

    target = 'themes/bridgepdx/stylesheets/common_css'
    backup = "#{target}.bak"

    rm(target) if File.symlink?(target)

    if File.directory?(target)
      rm_rf(backup) if File.exist?(backup)
      mv target, backup
    end

    ln_s(File.expand_path(ENV['DIR']), target)
  end

  namespace :wiki do
    def get_wiki_credentials
      return @get_wiki_credentials ||= begin
        require 'ostruct'

        missing = nil

        credentials          = OpenStruct.new
        credentials.user     = ENV['USER']     or missing = "USER"
        credentials.password = ENV['PASSWORD'] or missing = "PASSWORD"
        credentials.url      = ENV['URL']      or missing = "URL"

        if missing
          puts <<-HERE
MediaWiki credentials must include:
  * USER: The admin user to login to the wiki as.
  * PASSWORD: The admin user's password.
  * URL: The URL for the server's "api.php".

For example:
    rake --trace bridgepdx:wiki:populate USER=admin PASSWORD=secret URL=http://opensourcebridge.org/2011/w/api.php EVENT=2011
          HERE

          raise ArgumentError, "No #{missing} defined"
        else
          credentials
        end
      end
    end

    def sanitize_string(string)
      return CGI.unescape(Proposal._session_notes_url_escape(string))
    end

    def event_wiki_title(event)
      return "Category:#{sanitize_string(event.title)}"
    end
    
    def tracks_wiki_title(event)
      return "Category:#{sanitize_string(event.title)} tracks"
    end

    def track_wiki_title(track)
      #IK# return "Category:#{track.title} :: #{track.event.title}"
      return "Category:#{sanitize_string(track.title)}"
    end

    def session_wiki_title(session)
      #IK# return "#{session.title} :: #{session.event.title}"
      return "#{sanitize_string(session.title)}"
    end

    desc "Populates the attendee wiki with pages to hold session notes."
    task :populate => :environment do
      credentials = get_wiki_credentials
      wiki = RWikiBot::Bot.new(credentials.user, credentials.password, credentials.url, '', true)
      event = ENV['EVENT'] ? Event.find_by_slug(ENV['EVENT']) : Event.current

      # Event page
      drone = RwikibotPageDrone.new(wiki, event_wiki_title(event))
      drone.replace_span "description", "For details, see [#{SETTINGS.public_url} #{SETTINGS.organization}]."
      drone.save(true)

      # Tracks page
      drone = RwikibotPageDrone.new(wiki, tracks_wiki_title(event))
      drone.replace_span "description", "Tracks for [#{SETTINGS.public_url} #{SETTINGS.organization}]."
      drone.save(true)

      # Tracks
      event.tracks.all(:include => [:event]).each do |track|
        drone = RwikibotPageDrone.new(wiki, track_wiki_title(track))
        drone.append "[[#{event_wiki_title(track.event)}]]"
        drone.append "[[#{tracks_wiki_title(track.event)}]]"
        drone.replace_span "description", "#{textilize track.description}"
        drone.save(true)
      end
      
      # Sessions
      event.proposals.confirmed.all(:include => [:event, :track, :session_type]).each do |proposal|
        drone = RwikibotPageDrone.new(wiki, session_wiki_title(proposal))
        content = "[[#{event_wiki_title(proposal.event)} notes]] [[#{track_wiki_title(proposal.track)} notes]]"
        content << "#{textilize proposal.excerpt} " unless proposal.excerpt.blank?
        content << "<p>Speaker#{proposal.users.size > 1 ? 's' : ''}: #{proposal.users.map{|user| sprintf('[%susers/%s %s]', SETTINGS.app_root_url, user.id, user.fullname)}.join(', ')}</p>"
        content << "<p>Return to [#{sprintf '%ssessions/%s', SETTINGS.app_root_url, proposal.id} this session's details]</p>"
        content << "\n= Contributed notes =\n"
        drone.replace_span("generated", content)
        drone.append "<!-- DO NOT CHANGE ANYTHING ABOVE THIS LINE -->"
        drone.append "(Add your notes here!)"
        drone.save(true)
      end
    end
  end
end
