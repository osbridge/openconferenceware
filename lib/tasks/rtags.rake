desc "Create rtags file"
task :rtags do
  sh "rtags --vi --recurse app config lib"
end
