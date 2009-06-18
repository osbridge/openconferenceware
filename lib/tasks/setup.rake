namespace :setup do
  task :default => ["tmp:create", "db:migrate", "clear", :admin, :snippets, "db:test:prepare"] do
    puts <<-HERE

TO FINISH SETUP
1. See README.markdown for information about security and customization
2. Start the server, e.g.: ruby script/server
3. Login as "admin" to "/admin" URI, e.g.,: http://localhost:3000/admin}
4. Use the web-based admin interface to configure site
    HERE
  end

  desc %{Create or update the "admin" user and their password. Specify PASSWORD environmental variable to avoid prompt.}
  task :admin => "environment" do
    password = \
      if ENV["PASSWORD"]
        ENV["PASSWORD"]
      else
        print %{?? Enter the password to use for the "admin" user: }
        STDOUT.flush
        STDIN.readline
      end.strip

    if user = User.find_by_login("admin")
      user.change_password!(password)
      user.admin = true
      user.save!
      puts %{** Updated "admin" user's password}
    else
      user = User.new(
        :email => "admin",
        :login => "admin",
        :first_name => "Super",
        :last_name => "User",
        :biography => "I am all-powerful.",
        :password => password,
        :password_confirmation => password)
      user.login = "admin"
      user.admin = true
      user.save!
      puts "** Created new 'admin' user"
    end
  end

  desc "Load initial snippets of text. Use FORCE environmental variable to avoid prompt if these are already present."
  task :snippets => ["environment", "tmp:cache:clear", "tmp:create"] do
    replace = false
    perform = true
    if Snippet.count > 0 and not ENV["FORCE"]
      replace = true
      print "?? WARNING: Reset snippets back to defaults? (y/N) "
      STDOUT.flush
      response = STDIN.readline
      unless response.strip.match(/y/i)
        puts "** Not resetting snippets back to defaults"
        perform = false
      end
    end

    # TODO Merge snippets for Tickets and Proposals apps
    #IK# Rake::Task["snippets:load"].invoke if perform
    Snippet.reload_from_fixtures! if perform
  end

  desc "Destroy all data"
  task :destroy => ['clear'] do
    FileList['db/development.sqlite3', 'db/test.sqlite3'].each do |path|
      rm path if File.exist?(path)
    end
  end

  desc 'Load sample data, after destroying existing data and cache'
  task :sample => [:destroy, 'clear', 'db:migrate', 'spec:db:fixtures:load', 'setup:admin']
end

desc %{Setup application's database, "admin" user, and snippets}
task :setup => "setup:default"
