# Additional libraries are loaded in "config/initializers/libraries.rb".

# Repository:
source "https://rubygems.org"

# Rails version
gem 'rake', '~> 0.8.7'

# Rails version, which must be specified here AND in the environment.rb:
gem 'rails', '~> 2.3.18'

# Selectively-loaded:
gem 'facets',       '~> 2.8.0', :require => false # For initializers/dependencies.rb
gem 'mysql',        '~> 2.8.0', :require => false # For commonly used database driver
gem 'right_aws',    '~> 1.0',   :require => false # For paperclip
gem 'ruby-openid',  '~> 2.1.0', :require => false # For open_id_authentication
gem 'sqlite3-ruby', '~> 1.2.0', :require => false # For default database driver

# Necessary:
gem 'RedCloth',            '~> 4.2.3'
gem 'aasm',                '~> 2.1.5'
gem 'acts-as-taggable-on', '=  1.1.5'
gem 'color',               '~> 1.4.1'
gem 'deep_merge',          '~> 0.1.0'
gem 'fastercsv',           '~> 1.5.3'
gem 'gchartrb',            '~> 0.8.0', :require => 'google_chart'
gem 'hpricot',             '~> 0.8.2'
gem 'paperclip',           '~> 2.3.1'
gem 'vpim',                '=  0.695', :require => 'vpim/icalendar'
gem 'action_mailer_tls',   '~> 1.1.3'
gem 'nokogiri',            '~> 1.5.10'

gem 'prawn',               '= 0.11.1'

group :development do
  gem 'capistrano',     :require => false
  gem 'capistrano-ext', :require => false
end

group :test do
  gem 'test-unit',        '~> 1.2.3', :require => false
  gem 'cucumber',         '~> 0.6.2', :require => false
  gem 'cucumber-rails',   '~> 0.2.4', :require => false
  gem 'database_cleaner', '~> 0.4.3', :require => false
  gem 'factory_girl',     '~> 1.2.4', :require => false
  gem 'rspec',            '~> 1.3.0', :require => false
  gem 'rspec-rails',      '~> 1.3.0', :require => false
  gem 'webrat',           '~> 0.7.0', :require => false
end

# OPTIONAL LIBRARIES: These libraries upset travis-ci and may cause Ruby or
# RVM to hang, so only use them when needed.
if ENV['RUBYDEV']
  platform :mri_18 do
    gem 'rcov', :require => false
    gem 'ruby-debug'
  end

  platform :mri_19 do
    gem 'simplecov', :require => false
    gem 'debugger-ruby_core_source'
    gem 'debugger'
  end
end
