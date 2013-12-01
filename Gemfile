# Additional libraries are loaded in "config/initializers/libraries.rb".

# Repository:
source "https://rubygems.org"

# Rake version
gem 'rake'

# Rails version, which must be specified here AND in the environment.rb:
gem 'rails', '~> 3.2.0'

# Database driver
gem 'sqlite3', :require => false
# gem 'mysql2',  :require => false
# gem 'pg',      :require => false

# Authentication
gem 'omniauth-openid'
gem 'omniauth-persona'

# Selectively-loaded:
gem 'hashery',      :require => false # Dictionary used by CacheLookupsMixin
gem 'rwikibot',     '= 2.0.6',  :require => false,
                                :git => 'git://github.com/reidab/rwikibot.git'

# Necessary:
gem 'RedCloth',            '~> 4.2.3'
gem 'aasm'
gem 'acts-as-taggable-on'
gem 'color'
gem 'comma',               '~> 3.0'
gem 'gchartrb',            '~> 0.8.0', :require => 'google_chart'
gem 'hpricot',             '~> 0.8.2'
gem 'paperclip'
gem 'vpim-rails', :git => "https://github.com/osbridge/vpim-rails.git", :require => 'vpim/icalendar'
gem 'action_mailer_tls',   '~> 1.1.3'
gem 'nokogiri',            '~> 1.5.10'
gem 'prawn',               '= 0.11.1'
gem 'memcache-client'
gem "dynamic_form"
gem 'rinku', :require => 'rails_rinku'

platform :mri_18 do
  gem 'fastercsv',           '~> 1.5.3'
end

group :production do
  gem 'exception_notification'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl', '2.6.4'
end

group :development do
  gem 'capistrano',     :require => false
  gem 'capistrano-ext', :require => false

  platform :mri_18 do
    gem 'ruby-debug'
    gem 'ruby18_source_location'
  end

  gem 'debugger', :platforms => [:ruby_19, :ruby_20]

  gem 'pry'
end

group :test do
  gem 'test-unit',        '~> 1.2.3', :require => false
  gem 'database_cleaner', '~> 0.4.3', :require => false
  gem 'cucumber-rails',               :require => false
  gem 'launchy'
  gem 'capybara', '~> 2.0.0'

  platform :ruby_18 do
    gem 'rcov', :require => false
  end

  gem 'simplecov',     :require => false, :platforms => [:ruby_19, :ruby_20]
  gem 'cadre',         :require => false, :platforms => [:ruby_19, :ruby_20]
  gem 'coveralls',     :require => false, :platforms => [:ruby_19, :ruby_20]
end
