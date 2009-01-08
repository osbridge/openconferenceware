def timestamp(time=Time.now)
  time.strftime('%Y-%m-%d@%H%M')
end

desc "Tag as stable"
task :tag do
  sh "hg tag -f release_#{timestamp}"
  sh "hg tag -f stable"
end
