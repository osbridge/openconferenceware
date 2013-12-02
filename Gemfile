# Additional libraries are loaded in "config/initializers/libraries.rb".

# Repository:
source "https://rubygems.org"

# Rake version
gem 'rake'

# Rails version, which must be specified here AND in the environment.rb:
gem 'rails', '~> 3.2.0'

# Database driver
gem 'sqlite3', :require => false
gem 'mysql2',  :require => false
gem 'pg',      :require => false

# Authentication
gem 'omniauth-openid'
gem 'omniauth-persona'

# Selectively-loaded:
gem 'hashery',      :require => false # Dictionary used by CacheLookupsMixin
gem 'rwikibot',     :require => false, :git => 'git://github.com/reidab/rwikibot.git'

# Necessary:
gem 'RedCloth'
gem 'aasm'
gem 'acts-as-taggable-on'
gem 'color'
gem 'comma',               '~> 3.0'
gem 'gchartrb',            '~> 0.8.0', :require => 'google_chart'
gem 'paperclip'
gem 'vpim-rails', :git => "https://github.com/osbridge/vpim-rails.git", :require => 'vpim/icalendar'
gem 'action_mailer_tls',   '~> 1.1.3'
gem 'nokogiri'
gem 'prawn'
gem 'memcache-client'
gem "dynamic_form"
gem 'rinku', :require => 'rails_rinku'

group :production do
  gem 'exception_notification'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :development do
  gem 'capistrano',     '~> 2.15.0', :require => false
  gem 'capistrano-ext', :require => false

  gem 'debugger'

  gem 'pry'
end

group :test do
  gem 'database_cleaner', :require => false
  gem 'cucumber-rails',   :require => false
  gem 'launchy'
  gem 'capybara'
  gem 'guard-rspec', require: false

  gem 'simplecov',     :require => false
  gem 'cadre',         :require => false
  gem 'coveralls',     :require => false
end
