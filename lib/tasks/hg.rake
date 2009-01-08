namespace :hg do
  HG_TARGET='ssh://sumomo.koshevoy.net//var/www/ignite-proposals/'

  task :push do
    sh "hg push #{HG_TARGET}"
  end

  task :pull do
    sh "hg pull #{HG_TARGET}"
  end

  task :initialize do
    sh "rsync -uvax .hg #{HG_TARGET}"
  end
end

