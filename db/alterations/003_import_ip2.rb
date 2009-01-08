ip2 = Event.find(2) or raise "Can't find ip2"

# http://sqlite-ruby.rubyforge.org/sqlite3/faq.html
require 'sqlite3'
db = SQLite3::Database.new("db/ignite2.sqlite3")
columns, *rows = db.execute2("select * from proposals")
names2columns = {}
columns.each_with_index do |column, i|
  names2columns[column.to_sym] = i
end
n2s = names2columns
for row in rows
  proposal = Proposal.create!(
    :presenter    => row[n2s[:presenter]],
    :affiliation  => row[n2s[:affiliation]],
    :email        => row[n2s[:email]],
    :url          => row[n2s[:url]],
    :bio          => row[n2s[:bio]],
    :title        => row[n2s[:title]],
    :description  => row[n2s[:description]],
    :publish      => true,
    :agreement    => true,
    :event        => ip2,
    :submitted_at => row[n2s[:created_at]]
  )
end
