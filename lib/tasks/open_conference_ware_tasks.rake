namespace :open_conference_ware do
  namespace :setup do
    task :default => ['db:migrate', :snippets] do
      puts <<-HERE

  TO FINISH SETUP
  1. See README.markdown for information about security and customization
  2. Start the server, e.g.: bin/rails server
  3. Login as an admin in development mode
  4. Use the web-based admin interface to configure site
      HERE
    end

    desc 'Load sample data, after destroying existing data and cache'
    task :sample => ['tmp:create', 'db:migrate:reset', 'spec:db:fixtures:load', 'clear']
  end

  desc %{Setup application's database and snippets}
  task :setup => "setup:default"
end

