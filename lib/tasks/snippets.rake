namespace :open_conference_ware do
  namespace :snippets do
    desc "Load initial snippets of text. Use FORCE environmental variable to avoid prompt if these are already present."
    task :reload => ["environment"] do
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
  end
end
