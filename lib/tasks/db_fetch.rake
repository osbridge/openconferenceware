require 'lib/remote_params'

namespace :db do
  desc "Fetch production database and install it as the local instance"
  task :fetch do
    r = RemoteParams.get
    sh "scp #{r[:user_at_host_path]}/db/production.sqlite3 db/master.sqlite3"
    cp "db/master.sqlite3", "db/development.sqlite3"
    Rake::Task['clear'].invoke
  end
end
