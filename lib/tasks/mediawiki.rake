namespace :open_conference_ware do
  namespace :mediawiki do
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
    rake --trace open_conference_ware:mediawiki:populate USER=admin PASSWORD=secret URL=http://opensourcebridge.org/2011/w/api.php EVENT=2011
          HERE

          raise ArgumentError, "No #{missing} defined"
        else
          credentials
        end
      end
    end

    def sanitize_string(string)
      return CGI.unescape(OpenConferenceWare::Proposal._session_notes_url_escape(string))
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
      return "#{sanitize_string(session.event.slug)}/#{sanitize_string(session.title)}"
    end

    desc "Populates the attendee wiki with pages to hold session notes."
    task :populate => :environment do
      require 'lib/rwikibot_page_drone'

      credentials = get_wiki_credentials
      wiki = RWikiBot::Bot.new(credentials.user, credentials.password, credentials.url, '', true)
      event = ENV['EVENT'] ? OpenConferenceWare::Event.find_by_slug(ENV['EVENT']) : OpenConferenceWare::Event.current

      # Event page
      drone = RwikibotPageDrone.new(wiki, event_wiki_title(event))
      drone.replace_span "description", "For details, see [#{OpenConferenceWare.public_url} #{OpenConferenceWare.organization}]."
      drone.save(true)

      # Tracks page
      drone = RwikibotPageDrone.new(wiki, tracks_wiki_title(event))
      drone.replace_span "description", "Tracks for [#{OpenConferenceWare.public_url} #{OpenConferenceWare.organization}]."
      drone.save(true)

      # Tracks
      event.tracks.includes(:event).each do |track|
        drone = RwikibotPageDrone.new(wiki, track_wiki_title(track))
        drone.append "[[#{event_wiki_title(track.event)}]]"
        drone.append "[[#{tracks_wiki_title(track.event)}]]"
        drone.replace_span "description", "#{textilize track.description}"
        drone.save(true)
      end

      # Sessions
      event.proposals.confirmed.includes(:event, :track, :session_type).each do |proposal|
        drone = RwikibotPageDrone.new(wiki, session_wiki_title(proposal))
        content = "[[#{event_wiki_title(proposal.event)} notes]] [[#{track_wiki_title(proposal.track)} notes]]"
        content << "#{textilize proposal.excerpt} " unless proposal.excerpt.blank?
        content << "<p>Speaker#{proposal.users.size > 1 ? 's' : ''}: #{proposal.users.map{|user| sprintf('[%susers/%s %s]', OpenConferenceWare.app_root_url, user.id, user.fullname)}.join(', ')}</p>"
        content << "<p>Return to [#{sprintf '%ssessions/%s', OpenConferenceWare.app_root_url, proposal.id} this session's details]</p>"
        content << "\n= Contributed notes =\n"
        drone.replace_span("generated", content)
        drone.append "<!-- DO NOT CHANGE ANYTHING ABOVE THIS LINE -->"
        drone.append "(Add your notes here!)"
        drone.save(true)
      end
    end
  end
end
