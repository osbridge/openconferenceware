set :repository, '.'

set :scm, :git
set :deploy_via, :copy
set :copy_cache, true
set :copy_compression, :gzip
set :copy_exclude, ['.git', 'log', 'tmp', '*.sql', '*.diff', 'coverage.info', 'coverage', 'public/system', 'tags', 'db/*.yml', 'db/*.sql', 'db/*.sqlite3', '.*.swp']

set :deploy_to, '/var/www/bridgepdx_ocwdemo'
set :host, 'opensourcebridge.org'
set :user, 'bridgepdx'

role :app, host
role :web, host
role :db,  host, :primary => true
default_run_options[:pty] = true
