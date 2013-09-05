namespace :bridgepdx do
  desc "Fetch common styles from github and install them in the local instance"
  task :styles do
    sh "rm -rf tmp/style_clone"
    sh "git clone --depth 1 git://github.com/reidab/osbp_styles.git tmp/style_clone"
    sh "rsync -uvax --exclude='.git' --exclude='Rakefile' --exclude='README.markdown' tmp/style_clone/ public/stylesheets/common_css/"
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

  desc "Export per-room schedule CSV for InDesign merge"
  task :room_schedule => :environment do
    event = ENV['EVENT'].nil? ? Event.current : Event.find_by_slug(ENV['EVENT'])
    Prawn::Document.generate('RoomSchedule.pdf', :page_size => 'LETTER', :margin => [18,18,18,18]) do |pdf|
      pdf.font_families.update( "HelveticaNeueLTPro" => {
             :bold   => "HelveticaNeueLTPro-BdCn.ttf",
             :normal => "HelveticaNeueLTPro-Lt.ttf",
             :condensed => "HelveticaNeueLTPro-Cn.ttf",
             :ltcondensed => "HelveticaNeueLTPro-LtCn.ttf",
             :boldnormal => "HelveticaNeueLTPro-Bd.ttf",
             :roman => "HelveticaNeueLTPro-Roman.ttf"
           })

      event.rooms.each do |room|
        room.proposals.confirmed.group_by{|p| p.start_time.to_date}.each do |day, sessions|
          pdf.font "HelveticaNeueLTPro", :style => :boldnormal, :size => 30
          pdf.fill_color "000000"
          pdf.text "#{room.name}: #{day.strftime("%A, %B %d, %Y")}", :kerning => true

          sessions.sort_by{|s| s.start_time }.each do |session|
            pdf.font "HelveticaNeueLTPro", :style => :boldnormal, :size => 14
            pdf.fill_color 88, 55, 0, 0 # speaker blue
            pdf.text "#{session.start_time.strftime("%I:%M%p").gsub(/^0/,'')} \u002D #{session.end_time.strftime("%I:%M%p").gsub(/^0/,'')}", :kerning => true

            pdf.font "HelveticaNeueLTPro", :style => :boldnormal, :size => 18
            pdf.fill_color "000000"
            pdf.text session.title, :kerning => true

            pdf.font "HelveticaNeueLTPro", :style => :boldnormal, :size => 12
            pdf.fill_color 74, 0, 44, 0 # volunteer green
            pdf.text session.users.map{|u| u.fullname}.join(', '), :kerning => true

            pdf.move_down 2

            pdf.font "HelveticaNeueLTPro", :style => :roman, :size => 10
            pdf.fill_color "000000"
            pdf.text session.excerpt, :kerning => true

            pdf.move_down 15
          end
          pdf.start_new_page
        end
      end
    end

    # event = ENV['EVENT'].nil? ? Event.current : Event.find_by_slug(ENV['EVENT'])
    # FasterCSV.open('RoomSchedule.csv','w') do |csv|
    #   csv << ['room', 'day'] + (1..10).map{|n| ["s#{n}_start_time", "s#{n}_end_time", "s#{n}_title", "s#{n}_presenters", "s#{n}_excerpt", "s#{n}_track", "s#{n}_session_type"] }.flatten
    #   event.rooms.each do |room|
    #     room.proposals.confirmed.group_by{|p| p.start_time.to_date}.each do |day, sessions|
    #         row = []

    #       end
    #     end
    #   end
    # end

    # xml = ""
    # xm = Builder::XmlMarkup.new(:target => xml, :indent => 2)
    # event = ENV['EVENT'].nil? ? Event.current : Event.find_by_slug(ENV['EVENT'])

    # xm.instruct!
    # xm.Root do
    #   event.rooms.each do |room|
    #     room.proposals.confirmed.group_by{|p| p.start_time.to_date}.each do |day, sessions|
    #       xm.room_schedule do
    #         xm.schedule_title "#{room.name}: #{day.strftime("%A, %B %d, %Y")}"
    #         sessions.sort_by{|s| s.start_time }.each do |session|
    #           xm.session('id' => session.id) do
    #             # xm.start_time session.start_time.strftime("%I:%M%p")
    #             # xm.end_time session.end_time.strftime("%I:%M%p")
    #             xm.start_and_end "#{session.start_time.strftime("%I:%M%p")} — #{session.start_time.strftime("%I:%M%p")}"
    #             xm.title session.title
    #             xm.presenters session.users.map{|u| u.fullname}.join(', ')
    #             xm.excerpt do
    #               xm.cdata! session.excerpt
    #             end
    #             # xm.session_type session.session_type && session.session_type.title
    #             # xm.track session.track.title
    #             # xm.description session.description
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

    # File.write('RoomSchedule.xml', xml)
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

    target = 'public/stylesheets/common_css'
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
      return "#{sanitize_string(session.event.slug)}/#{sanitize_string(session.title)}"
    end

    desc "Populates the attendee wiki with pages to hold session notes."
    task :populate => :environment do
      require 'lib/rwikibot_page_drone'

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
