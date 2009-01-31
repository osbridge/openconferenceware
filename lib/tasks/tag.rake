def timestamp(time=Time.now)
  time.strftime('%Y%m%dT%H%M')
end

desc "Tag as stable"
task :tag do
  sh "git tag -f release_#{timestamp}"
  sh "git tag -f stable"
  sh "git tag -l | head"
end
