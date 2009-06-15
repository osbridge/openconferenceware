namespace :bridgepdx do
  desc "Fetch common styles from github and install them in the local instance"
  task :styles do
    sh "rm -rf tmp/style_clone"
    sh "git clone --depth 1 git://github.com/reidab/osbp_styles.git tmp/style_clone"
    sh "rsync -uvax --exclude='.git' --exclude='Rakefile' --exclude='README.markdown' tmp/style_clone/ themes/bridgepdx/stylesheets/common_css/"
    sh "rm -rf tmp/style_clone"
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
    rake bridgepdx:wiki:populate USER=admin PASSWORD=secret URL=http://localhost/wiki/api.php
          HERE

          raise ArgumentError, "No #{missing} defined"
        else
          credentials
        end
      end
    end

    desc "Populates the attendee wiki with pages to hold session notes."
    task :populate => :environment do
      credentials = get_wiki_credentials
      wiki = RWikiBot::Bot.new(credentials.user, credentials.password, credentials.url, '', true)
      
      Event.current.tracks.all(:include => [:event]).each do |track|
        puts "Creating Track: '#{track.title}'"
        @track = track 
        template = ERB.new <<-HERE
          [[Category:Tracks]]
          [[Category:<%= @track.event.title%>]]
        HERE
        wiki.page("Category:#{track.title}").save(template.result)
      end
      
      Event.current.proposals.confirmed.all(:include => [:event, :track, :session_type]).each do |proposal|
        puts "Creating '#{proposal.title}'"
        @proposal = proposal
        template = ERB.new <<-HERE
          [[Category:Session Notes]]
          [[Category:<%= @proposal.event.title%>]]
          [[Category:<%= @proposal.track.title %>]]
          [[Category:<%= @proposal.session_type.title %>]]
        HERE
        wiki.page(proposal.title).save(template.result)
      end
    end
  end
end
