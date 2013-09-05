set :scm, "git"
set :repository,  "#{ENV['HOME']}/workspace/openconferenceware"
set :deploy_to, "/var/www/bridgepdx_ocw"
set :host, "localhost"

set :deploy_via, :remote_cache
role :app, host
role :web, host
role :db,  host, :primary => true
