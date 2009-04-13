# = Capistrano deployment for OpenConferenceWare instances
#
# To deploy the application using Capistrano, you must:
#
#  1. Install Capistrano and the multistage extension on your local machine:
#       sudo gem install capistrano capistrano-ext
#
#  2. Create or use a stage file as defined in the "config/deploy/" directory.
#     Read the other files in that directory for ideas. You will need to use
#     the name of your configuration in all remote calls. E.g., if you created
#     a "config/deploy/mysite.rb" (thus "mysite"), you will run commands like
#     "cap mysite deploy" to deploy using your "mysite" configuration.
#
#  3. Setup your server if this is the first time you're deploying, e.g.,:
#       cap mysite deploy:setup
#
#  4. Create the "shared/config/secrets.yml" on your server to store secret
#     information. See the "config/secrets.yml.sample" file for details. If you
#     try deploying to a server without this file, you'll get instructions with
#     the exact path to put this file on the server.
#
#  5. Create the "shared/config/database.yml" on your server with the database
#     configuration. This file must contain absolute paths if you're using
#     SQLite. If you try deploying to a server without this file, you'll get
#     instructions with the exact path to put this file on the server.
#
#  6. Push your revision control changes and then deploy, e.g.,:
#       cap mysite deploy
#
#  7. If you have migrations that need to be applied, deploy with them, e.g.,:
#       cap mysite deploy:migrations
#
#  8. If you deployed a broken revision, you can rollback to the previous, e.g.,:
#       cap mysite deploy:rollback
ssh_options[:compression] = false

set :application, "openproposals"
set :use_sudo, false

# Load stages from config/deploy/*
set :stages, Dir["config/deploy/*.rb"].map{|t| File.basename(t, ".rb")}
require 'capistrano/ext/multistage'

# :current_path - 'current' symlink pointing at current release
# :release_path - 'release' directory being deployed
# :shared_path - 'shared' directory with shared content

namespace :deploy do
  desc "Restart Passenger application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t.inspect} task is a no-op with Passenger"
    task t, :roles => :app do
      # Do nothing
    end
  end

  desc "Prepare shared directories"
  task :prepare_shared do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/db"
  end

  desc "Set the application's secrets"
  task :secrets_yml do
    source = "#{shared_path}/config/secrets.yml"
    target = "#{release_path}/config/secrets.yml"
    begin
      run %{if test ! -f #{source}; then exit 1; fi}
      run %{ln -nsf #{source} #{target}}
    rescue Exception => e
      puts <<-HERE
ERROR!  You must have a file on your server to store secret information.
        See the "config/secrets.yml.sample" file for details on this.
        You will need to upload your completed file to your server at:
            #{source}
      HERE
      raise e
    end
  end

  desc "Generate database.yml"
  task :database_yml do
    source = "#{shared_path}/config/database.yml"
    target = "#{release_path}/config/database.yml"
    begin
      run %{if test ! -f #{source}; then exit 1; fi}
      run %{ln -nsf #{source} #{target}}
    rescue Exception => e
      puts <<-HERE
ERROR!  You must have a file on your server with the database configuration.
        This file must contain absolute paths if you're using SQLite.
        You will need to upload your completed file to your server at:
            #{source}
      HERE
      raise e
    end
  end

  desc "Set the application's theme"
  task :theme_txt do
    run "echo #{theme} > #{release_path}/config/theme.txt"
  end

  desc "Clear the application's cache"
  task :clear_cache do
    run "(cd #{current_path} && rake RAILS_ENV=production clear)"
  end
end

# After setup
after "deploy:setup", "deploy:prepare_shared"

# After finalize_update
after "deploy:finalize_update", "deploy:database_yml"
after "deploy:finalize_update", "deploy:secrets_yml"
after "deploy:finalize_update", "deploy:theme_txt"

# After symlink
after "deploy:symlink", "deploy:clear_cache"
