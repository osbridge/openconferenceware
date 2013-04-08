set :scm, "git"
set :branch, "master" unless variables[:branch]
set :repository,  "git@github.com:igal/openproposals.git"
set :deploy_to, "/var/www/proposals.ignitebend.com"
set :user, "igal"
set :host, "sumomo"

set :deploy_via, :remote_cache
role :app, host
role :web, host
role :db,  host, :primary => true
default_run_options[:pty] = true
