Rake::TestTask.new('test:all' => 'db:test:prepare') do |t|
  t.libs << 'test'
  t.pattern = 'test/*/**/*_test.rb'
  t.verbose = true
end
Rake::Task['test:all'].comment = 'Test everything'
