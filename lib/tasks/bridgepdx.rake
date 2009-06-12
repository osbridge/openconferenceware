namespace :bridgepdx do
  desc "Fetch common styles from github and install them in the local instance"
  task :styles do
    sh "rm -rf tmp/style_clone"
    sh "git clone --depth 1 git://github.com/reidab/osbp_styles.git tmp/style_clone"
    sh "rsync -uvax --exclude='.git' --exclude='Rakefile' --exclude='README.markdown' tmp/style_clone/ themes/bridgepdx/stylesheets/common_css/"
    sh "rm -rf tmp/style_clone"
  end
  
  namespace :wiki do
    desc "Populates the attendee wiki with pages to hold session notes."
    task :populate => :environment do
      wiki = RWikiBot::Bot.new('admin','1adam12','http://localhost/web/mediawiki/api.php','',true)
      
      Event.current.tracks.each do |track|
        puts "Creating Track: '#{track.title}'"
        @track = track
        template = ERB.new <<-HERE
          [[Category:Tracks]]
          [[Category:<%= @track.event.title%>]]
        HERE
        wiki.page("Category:#{track.title}").save(template.result)
      end
      
      Event.current.proposals.confirmed.each do |proposal|
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