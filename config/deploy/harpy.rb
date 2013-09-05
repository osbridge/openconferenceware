set :scm, "git"
set :repository,  "#{File.dirname(File.dirname(File.dirname(__FILE__)))}"
set :deploy_to, "/var/www/bridgepdx_ocw"
set :host, "harpy"
set :user, "bridgepdx"

set :deploy_via, :copy
set :copy_cache, true
set :copy_compression, :gzip
set :copy_exclude, ['.git', 'log', 'tmp', '*.sql', '*.diff', 'coverage.info', 'coverage', 'public/system', 'tags', 'db/*.yml', 'db/*.sql', 'db/*.sqlite3', '.*.swp']

role :app, host
role :web, host
role :db,  host, :primary => true
