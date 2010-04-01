# Additional libraries are loaded in "config/initializers/libraries.rb".

# Repository:
source :gemcutter

# Rails version, which must be specified here AND in the environment.rb:
gem 'rails', '~> 2.1.2'

# Selectively-loaded:
gem 'facets',       '~> 2.8.0', :require => false # For initializers/dependencies.rb
gem 'mysql',        '~> 2.8.0', :require => false # For commonly used database driver
gem 'right_aws',    '~> 1.0',   :require => false # For paperclip
gem 'ruby-openid',  '~> 2.1.0', :require => false # For open_id_authentication
gem 'sqlite3-ruby', '~> 1.2.0', :require => false # For default database driver

# Necessary:
gem 'RedCloth',            '~> 4.2.3'
gem 'aasm',                '~> 2.1.5'
gem 'acts-as-taggable-on', '~> 1.1.5'
gem 'color',               '~> 1.4.1'
gem 'deep_merge',          '~> 0.1.0'
gem 'fastercsv',           '~> 1.5.3'
gem 'gchartrb',            '~> 0.8.0', :require => 'google_chart'
gem 'hpricot',             '~> 0.8.2'
gem 'paperclip',           '~> 2.3.1'
gem 'vpim',                '=  0.695', :require => 'vpim/icalendar'

group :development do
  gem 'capistrano',     :require => false
  gem 'capistrano-ext', :require => false
  gem 'ruby-debug',     :require => false
end

group :test do
  gem 'cucumber',         '~> 0.6.2', :require => false
  gem 'cucumber-rails',   '~> 0.2.4', :require => false
  gem 'database_cleaner', '~> 0.4.3', :require => false
  gem 'factory_girl',     '~> 1.2.4', :require => false
  gem 'rcov',             '~> 0.9.7', :require => false
  gem 'rspec',            '~> 1.3.0', :require => false
  gem 'rspec-rails',      '~> 1.3.0', :require => false
  gem 'webrat',           '~> 0.7.0', :require => false
end
