namespace :open_conference_ware do
  namespace :schedule do
    namespace :import do
      desc "Import schedule from CSV file."
      task :csv => :environment do
        unless ENV['CSV'] and ENV['EVENT']
          puts <<-HERE
  schedule:import:csv

  Usage:
    rake schedule:import:csv RAILS_ENV=production EVENT=2010 CSV=schedule.csv

  CSV format:
    Your CSV file must have a header with these titles and data:
    * date
    * time
    * proposal_id
          HERE
          exit 1
        end

        event_slug = ENV['EVENT']
        csv_file = ENV['CSV']

        event = Event.find_by_slug(event_slug)
        puts "* Loaded event by slug: #{event.slug}"

        has_seen_header = false
        puts "* Reading CSV file: #{csv_file}"
        CSV.foreach(csv_file) do |row|
          date, time, proposal_id = row
          if has_seen_header
            proposal = Proposal.find(proposal_id)
            datetime = Time.zone.parse "#{date} #{time}"
            puts "- Setting #{datetime.inspect} for #{proposal.title}"
            proposal.update_attribute(:start_time, datetime)
          else
            expected_header = %w[date time proposal_id]
            unless expected_header == row
              puts "ERROR: your CSV file header must be #{expected_header.inspect}"
              exit 1
            end
            puts "* Validated CSV header"
            has_seen_header = true
          end
        end
      end

      desc "Import schedule from Google Spread Sheet"
      task :google_spreadsheet => :environment do
        require 'google_spreadsheet'

        if raw = SECRETS.schedule_google_spreadsheet
          auth = OpenStruct.new(raw)
        else
          puts <<-HERE
  ERROR: No credentials found for importing. Please add your credentials in the
        following format to your "config/secrets.yml" file:

      schedule_google_spreadsheet:
        login: 'your@google.account'
        password: 'your_password'
        key: 'your_key'

          HERE
          raise ArgumentError, "No credentials"
        end

        gs = GoogleSpreadsheet.login(auth.login, auth.password).spreadsheet_by_key(auth.key)

        print "- Loading ... "
        STDOUT.flush
        data = gs.worksheets.select{|sheet| sheet.title.include?("Exportable")}.map do |sheet|
          sheet.rows[1..-1].map do |row|
            {
              :id => row[0],
              :room_id => row[1],
              :start_time => Time.zone.parse("#{row[2]} #{row[3]}")
            }
          end
        end.flatten
        puts "#{data.size} records"

        print "- Saving ..."
        STDOUT.flush
        data.each do |scheduled|
          if scheduled[:id].to_i > 0
            begin
              session = Proposal.find(scheduled[:id])
              session.room_id = scheduled[:room_id]
              session.start_time = scheduled[:start_time]
              session.save
            rescue ActiveRecord::RecordNotFound
              puts "! Unknown record: #{scheduled.inspect}"
            end
          end
        end
        puts "done!"

      end
    end
  end
end
