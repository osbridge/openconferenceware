require 'google_spreadsheet'

GOOGLE_LOGIN = ''
GOOGLE_PASSWORD = ''
SPREADSHEET_KEY = ''

@gs = GoogleSpreadsheet.login(GOOGLE_LOGIN, GOOGLE_PASSWORD).spreadsheet_by_key(SPREADSHEET_KEY)

data = @gs.worksheets.select{|sheet| sheet.title.include?("Exportable")}.map do |sheet|
  sheet.rows[1..-1].map do |row|
    {
      :id => row[0],
      :room_id => row[1],
      :start_time => Time.zone.parse("#{row[2]} #{row[3]}")
    }
  end
end.flatten

data.each do |scheduled|
  if scheduled[:id].to_i > 0
    begin
      session = Proposal.find(scheduled[:id])
      session.room_id = scheduled[:room_id]
      session.start_time = scheduled[:start_time]
      session.save
    rescue ActiveRecord::RecordNotFound
    end
  end
end