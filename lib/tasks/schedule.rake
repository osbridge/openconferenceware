namespace :schedule do
  namespace :import do
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
