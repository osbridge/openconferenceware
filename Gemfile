# Additional libraries are loaded in "config/initializers/libraries.rb".

# Repository:
source :gemcutter

# Rails version, which must be specified here AND in the environment.rb:
gem "rails", "~> 2.1.2", :require => nil

# Selectively-loaded:
gem 'sqlite3-ruby', :lib => false # For default database driver
gem 'mysql',        :lib => false # For commonly used database driver
gem 'ruby-openid',  :lib => false # For open_id_authentication
gem 'facets',       :lib => false # For initializers/dependencies.rb
gem 'right_aws',    :lib => false # For paperclip

# Necessary:
gem 'acts-as-taggable-on', :version => '~> 1.1.5'
gem 'paperclip',           :version => '~> 2.3.1'
gem 'aasm',                :version => '~> 2.1.5'
gem 'gchartrb',            :lib => 'google_chart'
gem 'vpim',                :lib => 'vpim/icalendar'
gem 'RedCloth'
gem 'color'
gem 'deep_merge'
gem 'hpricot'
gem 'fastercsv'

group :development do
  gem 'ruby-debug',     :lib => false
  gem 'capistrano',     :lib => false
  gem 'capistrano-ext', :lib => false
end

group :test do
  gem 'rcov',             :version => '~> 9.7',   :lib => false
  gem 'rspec',            :version => '~> 1.3.0', :lib => false
  gem 'rspec-rails',      :version => '~> 1.3.0', :lib => false
  gem 'cucumber',         :version => '~> 0.6.2', :lib => false
  gem 'cucumber-rails',   :version => '~> 0.2.4', :lib => false
  gem 'webrat',           :version => '~> 0.7.0', :lib => false
  gem 'database_cleaner', :version => '~> 0.4.3', :lib => false
end
