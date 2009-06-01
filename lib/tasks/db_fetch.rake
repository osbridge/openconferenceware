require 'lib/remote_params'

namespace :db do
  desc "Fetch production database and install it as the local instance"
  task :fetch do
    filename = 'dump.sql'
    r = RemoteParams.get
    remote_path = File.join(r[:path], "..", "current")

    sh %{ssh #{r[:user_at_host]} "cd #{remote_path} && rake db:raw:dump RAILS_ENV=production FILE=#{filename}"}
    sh "rsync -uv #{r[:user_at_host]}:#{remote_path}/#{filename} ."

    ENV['FILE'] = filename
    Rake::Task['db:raw:restore'].invoke
    Rake::Task['clear'].invoke
  end
end
