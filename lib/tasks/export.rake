namespace :export do
  def write_file(name, data)
    File.open(name,'w') {|f| f.write( data )}
  end

  # -[ Speakers ]---------------

  namespace :speakers do
    def speakers
      Proposal.confirmed.populated.map(&:users).flatten.sort_by(&:last_name).uniq
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
      User.find(:all, :order => 'last_name')
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
end