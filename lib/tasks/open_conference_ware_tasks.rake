namespace :open_conference_ware do
  namespace :setup do
    task :default => ['tmp:create', 'db:migrate:reset', :snippets, 'db:test:prepare'] do
      puts <<-HERE

  TO FINISH SETUP
  1. See README.markdown for information about security and customization
  2. Start the server, e.g.: bin/rails server
  3. Login as an admin in development mode
  4. Use the web-based admin interface to configure site
      HERE
    end

    desc "Load initial snippets of text. Use FORCE environmental variable to avoid prompt if these are already present."
    task :snippets => ["environment", "tmp:cache:clear", "tmp:create"] do
      replace = false
      perform = true
      if OpenConferenceWare::Snippet.count > 0 and not ENV["FORCE"]
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
      OpenConferenceWare::Snippet.reload_from_fixtures! if perform
    end

    desc 'Load sample data, after destroying existing data and cache'
    task :sample => ['tmp:create', 'db:migrate:reset', 'spec:db:fixtures:load', 'clear']
  end

  desc %{Setup application's database, and snippets}
  task :setup => "setup:default"
end
