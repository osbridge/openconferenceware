set :scm, :mercurial
set :deploy_via, :remote_cache
set :repository, "ssh://hg@dev.pragmaticraft.com/ignite5proposals"

set :deploy_to, "/var/www/ignite5proposals"
set :user, "igal"
set :host, "sumomo"
role :app, host
role :web, host
role :db,  host, :primary => true

set :theme, "igniteportland"
