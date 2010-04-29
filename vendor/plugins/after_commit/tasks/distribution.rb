require 'rake/rdoctask'
require 'jeweler'

desc 'Generate documentation for the after_commit plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AfterCommit'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Jeweler::Tasks.new do |gem|
  gem.name = 'after_commit'
  gem.summary = 'after_commit callback for ActiveRecord'
  gem.description = %Q{
    A Ruby on Rails plugin to add an after_commit callback. This can be used to trigger methods only after the entire transaction is complete.
  }
  gem.email = "pat@freelancing-gods.com"
  gem.homepage = "http://github.com/freelancing-god/after_commit"
  gem.authors = ["Nick Muerdter", "David Yip", "Pat Allan"]

  gem.files = FileList[
    'lib/**/*.rb',
    'LICENSE',
    'rails/**/*.rb',
    'README'
  ]
  gem.test_files = FileList[
    'test/**/*.rb'
  ]

  gem.add_dependency 'activerecord'
  gem.add_development_dependency 'shoulda'
end
