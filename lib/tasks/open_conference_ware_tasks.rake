namespace :open_conference_ware do
  desc %{Setup application's database and seed data}
  task :setup => ['db:migrate', 'db:seed'] do
    puts <<-HERE

TO FINISH SETUP
1. See README.markdown for information about security and customization
2. Start the server, e.g.: bin/rails server
3. Sign in as an admin in development mode
4. Use the web-based admin interface to create and configure an event
    HERE
  end
end

