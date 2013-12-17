namespace :open_conference_ware do
  desc %{Setup application's database and seed data}
  task :setup => ['db:migrate', 'db:seed'] do
    puts <<-HERE

TO FINISH SETUP
1. See README.md for information about configuration and customization
2. Edit config/initializers/01_open_conference_ware.rb and config/secrets.yml
2. Start the server: bin/rails server
3. Sign in as an admin in development mode
4. Use the web-based admin interface to create and configure an event
    HERE
  end
end

Rake::Task["open_conference_ware:install:migrations"].clear
