namespace :open_conference_ware do
  namespace :export do
    def write_file(name, data)
      File.open(name,'w') {|f| f.write( data )}
    end

    # -[ Speakers ]---------------

    namespace :speakers do
      def speakers
        scope = ENV["EVENT"] ? Event.find_by_slug(ENV["EVENT"]).proposals : Proposal
        return scope.confirmed.populated.map(&:users).flatten.sort_by(&:last_name).uniq
      end

      desc "Exports basic speaker badge information to speakers.csv"
      task :brief => :environment do
        write_file( 'speakers.csv', speakers.to_comma(:brief) )
        puts "Basic speaker information written to speakers.csv"
      end

      desc "Exports full speaker information to speakers.csv"
      task :full => :get_speakers do
        write_file( 'speakers.csv', speakers.to_comma(:full) )
        puts "Full speaker information written to speakers.csv"
      end
    end

    desc "See: export:speakers:brief"
    task :speakers => 'speakers:brief'

    # -[ Users ]---------------

    namespace :users do
      def users
        User.order('last_name')
      end

      desc "Exports basic user information to users.csv"
      task :brief => :environment do
        write_file( 'users.csv', users.to_comma(:brief) )
        puts "Basic user information written to users.csv"
      end

      desc "Exports full user information to speakers.csv"
      task :full => :get_speakers do
        write_file( 'users.csv', users.to_comma(:full) )
        puts "Full user information written to users.csv"
      end
    end

    desc "See: export:users:brief"
    task :users => 'users:brief'

    # -[ Sessions ]------------

    desc "Export session information CSV for schedule monitor cards"
    task :session_card_csv => :environment do
      event = ENV['EVENT'].nil? ? OpenConferenceWare::Event.current : OpenConferenceWare::Event.find_by_slug(ENV['EVENT'])
      CSV.open('session_cards.csv','w') do |csv|
        csv << %w(room start_time title speakers)
        event.proposals.confirmed.order('start_time ASC').each do |session|
          row = []
          row << (session.room ? session.room.name : '')
          row << session.start_time.strftime("%A, %B %d, %I:%M%p")
          row << session.title
          row << session.users.map{|u| u.fullname}.join(', ')
          csv << row
        end
      end
    end

    namespace :room_schedule do
      desc "Export per-room schedule PDF"
      task :pdf => :environment do
        event = ENV['EVENT'].nil? ? OpenConferenceWare::Event.current : OpenConferenceWare::Event.find_by_slug(ENV['EVENT'])
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
      end

      desc "Export per-room schedule CSV"
      task :csv => :environment do

        event = ENV['EVENT'].nil? ? OpenConferenceWare::Event.current : OpenConferenceWare::Event.find_by_slug(ENV['EVENT'])
        CSV.open('RoomSchedule.csv','w') do |csv|
          csv << ['room', 'day'] + (1..10).map{|n| ["s#{n}_start_time", "s#{n}_end_time", "s#{n}_title", "s#{n}_presenters", "s#{n}_excerpt", "s#{n}_track", "s#{n}_session_type"] }.flatten
          event.rooms.each do |room|
            room.proposals.confirmed.group_by{|p| p.start_time.to_date}.each do |day, sessions|
                row = []
            end
          end
        end
      end

      desc "Export per-room schedule XML"
      task :xml => :environment do
        xml = ""
        xm = Builder::XmlMarkup.new(:target => xml, :indent => 2)
        event = ENV['EVENT'].nil? ? OpenConferenceWare::Event.current : OpenConferenceWare::Event.find_by_slug(ENV['EVENT'])

        xm.instruct!
        xm.Root do
          event.rooms.each do |room|
            room.proposals.confirmed.group_by{|p| p.start_time.to_date}.each do |day, sessions|
              xm.room_schedule do
                xm.schedule_title "#{room.name}: #{day.strftime("%A, %B %d, %Y")}"
                sessions.sort_by{|s| s.start_time }.each do |session|
                  xm.session('id' => session.id) do
                    # xm.start_time session.start_time.strftime("%I:%M%p")
                    # xm.end_time session.end_time.strftime("%I:%M%p")
                    xm.start_and_end "#{session.start_time.strftime("%I:%M%p")} - #{session.start_time.strftime("%I:%M%p")}"
                    xm.title session.title
                    xm.presenters session.users.map{|u| u.fullname}.join(', ')
                    xm.excerpt do
                      xm.cdata! session.excerpt
                    end
                    # xm.session_type session.session_type && session.session_type.title
                    # xm.track session.track.title
                    # xm.description session.description
                  end
                end
              end
            end
          end
        end

        File.write('RoomSchedule.xml', xml)
      end
    end

  end
end
