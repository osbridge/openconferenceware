require 'rake/testtask'

desc 'Test the after_commit plugin.'
Rake::TestTask.new(:test) do |t|
  test_dir = File.expand_path(File.join(File.dirname(__FILE__), %w(.. test)))

  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.ruby_opts = ["-I#{test_dir}"]
end

task :test => :check_dependencies
