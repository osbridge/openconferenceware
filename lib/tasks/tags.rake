desc "Create tags file"
task :tags do
  which = lambda{|command| File.exist?(`which #{command} 2>&1`.chomp)}
  if which['ctags']
    sh "ctags --totals=yes --recurse app config lib"
  elsif which['rtags']
    sh "rtags --vi --recurse app config lib"
  else
    raise NotSupportedException, "Could not create tags, please install ctags or rtags."
  end
end

task :rtags => :tags
task :ctags => :tags
