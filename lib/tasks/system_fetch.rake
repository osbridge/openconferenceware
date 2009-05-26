require 'lib/remote_params'

namespace :system do
  desc "Fetch system directory from server"
  task :fetch do
    r = RemoteParams.get
    sh "rsync -uvax --stats #{r[:user_at_host_path]}/system/ #{RAILS_ROOT}/public/system/"
  end
end
