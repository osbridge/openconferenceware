# = Capistrano deployment for Ignite Proposals application
#
# To deploy the application using Capistrano, you must:
#
#  1. Create a "config/secrets.yml" file from the "config/secrets.yml.sample"
#     file. This will be will be uploaded to the servers by the "deploy:setup"
#     step. Do not simply run using the default because it uses publicly-known
#     keys that will let others compromise your application, and you will also
#     not be notified of exceptions. That would be bad.
#
#  2. Install the Capistrano multistage extension on the machine running the
#     `cap` command:
#       sudo gem install capistrano-ext
#
#  3. Create or use a stage file as defined in the "config/deploy/" directory.
#     Read the other files in that directory for ideas.
#
#  4. Specify the stage in all your deploy calls, e.g.,:
#       cap igniteportland deploy
#
#  5. Setup your servers if this is the first time you're deploying, e.g.,:
#       cap igniteportland deploy:setup
#
#  6. Push your revision control changes and then deploy, e.g.,:
#       cap igniteproposals deploy
#
#  7. If you have migrations that need to be applied, deploy with them, e.g.,:
#       cap igniteproposals deploy:migrations

ssh_options[:compression] = false

set :application, "igniteproposals"
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

  desc "Upload config/secrets.yml to server's shared directory"
  task :upload_secrets_yml do
    put File.read("config/secrets.yml"), "#{shared_path}/config/secrets.yml", :mode => 0664
  end

  desc "Generate database.yml"
  task :database_yml do
    run %{ruby -p -i.bak -e '$_.gsub!(%r{database: db/}, "database: #{shared_path}/db/")' #{current_path}/config/database.yml}
  end

  desc "Set the application's secrets"
  task :secrets_yml do
    run "ln -nsf #{shared_path}/config/secrets.yml #{current_path}/config/secrets.yml"
  end

  desc "Set the application's theme"
  task :theme_txt do
    run "echo #{theme} > #{current_path}/config/theme.txt"
  end

  desc "Clear the application's cache"
  task :clear_cache do
    run "(cd #{current_path} && rake RAILS_ENV=production tmp:clear theme_remove_cache)"
  end
end

# After setup
after "deploy:setup", "deploy:prepare_shared"
after "deploy:setup", "deploy:upload_secrets_yml"

# After symlink
after "deploy:symlink", "deploy:database_yml"
after "deploy:symlink", "deploy:secrets_yml"
after "deploy:symlink", "deploy:theme_txt"
after "deploy:symlink", "deploy:clear_cache"
