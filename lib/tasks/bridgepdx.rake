namespace :bridgepdx do
  desc "Fetch common styles from github and install them in the local instance"
  task :styles do
    sh "rm -rf tmp/style_clone"
    sh "git clone --depth 1 git://github.com/reidab/osbp_styles.git tmp/style_clone"
    sh "rsync -uvax --exclude='.git' --exclude='Rakefile' --exclude='README.markdown' tmp/style_clone/ themes/bridgepdx/stylesheets/common_css/"
    sh "rm -rf tmp/style_clone"
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
    rake bridgepdx:wiki:populate USER=admin PASSWORD=secret URL=http://localhost/wiki/api.php
          HERE

          raise ArgumentError, "No #{missing} defined"
        else
          credentials
        end
      end
    end

    def event_wiki_title(event)
      return "Category:#{event.title}"
    end
    
    def tracks_wiki_title(event)
      return "Category:#{event.title} tracks"
    end

    def track_wiki_title(track)
      #IK# return "Category:#{track.title} :: #{track.event.title}"
      return "Category:#{track.title}"
    end

    def session_wiki_title(session)
      #IK# return "#{session.title} :: #{session.event.title}"
      return "#{session.title}"
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
        drone.append "[[#{event_wiki_title(proposal.event)}]]"
        drone.append "[[#{track_wiki_title(proposal.track)}]]"
        #drone.replace_span "description", "#{textilize proposal.description}"
        drone.replace_span "excerpt", "#{textilize proposal.excerpt}" unless proposal.excerpt.blank?
        drone.replace_span "speakers", "Speaker#{proposal.users.size > 1 ? 's' : ''}: #{proposal.users.map{|user| sprintf('[%susers/%s %s]', SETTINGS.app_root_url, user.id, user.fullname)}.join(', ')}"
        drone.replace_span "back", "\nReturn to [#{sprintf '%ssessions/%s', SETTINGS.app_root_url, proposal.id} this session's details]"
        drone.append "= Contributed notes ="
        #drone.append "\n\n----\n''Add your notes above this line''"
        drone.save(true)
      end
    end
  end
end
