$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "open_conference_ware/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "open_conference_ware"
  s.version     = OpenConferenceWare::VERSION
  s.authors     = ["Igal Koshevoy", "Reid Beels", "Kirsten Comandich", "Audrey Eschright", "et al."]
  s.email       = ["reid@opensourcebridge.org"]
  s.homepage    = "http://openconferenceware.org"
  s.summary     = "An open source web application for events and conferences. "
  s.description = "OpenConferenceWare is an open source web application for events and conferences. This customizable, general-purpose platform provides proposals, sessions, schedules, tracks and more."

  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")

  cert = File.expand_path("~/.ssh/gem-private_key_ocw.pem")
  if File.exist?(cert)
    s.signing_key = cert
    s.cert_chain = ["gem-public_cert.pem"]
  end

  s.add_dependency "rails", "~> 4.0.2"
  s.add_dependency "rails-observers", "~> 0.1.2"

  # Authentication
  s.add_dependency "omniauth",            '~> 1.2.0'

  s.add_dependency "hashery",             '~> 2.1.0'

  s.add_dependency 'RedCloth',            '~> 4.2.0'
  s.add_dependency 'aasm',                '~> 3.1.0'
  s.add_dependency 'acts-as-taggable-on', '~> 3.0.0'
  s.add_dependency 'color',               '~> 1.5.1'
  s.add_dependency 'comma',               '~> 3.0'
  s.add_dependency 'gchartrb',            '~> 0.8.0'
  s.add_dependency 'paperclip',           '~> 4.1.0'
  s.add_dependency 'vpim',                '~> 13.11.11'
  s.add_dependency 'nokogiri',            '~> 1.6.0'
  s.add_dependency 'prawn',               '~> 0.12.0'
  s.add_dependency "dynamic_form",        '~> 1.1.4'
  s.add_dependency 'rinku',               '~> 1.7.3'

  # Assets
  s.add_dependency 'jquery-rails',        '~> 3.1.0'
  s.add_dependency 'sass-rails',          '~> 4.0.0'
  s.add_dependency 'uglifier',            '~> 2.4.0'

  # Development
  s.add_development_dependency "sqlite3", '~> 1.3.0'

  # Testing
  s.add_development_dependency 'rspec-rails',         '~> 2.14.0'
  s.add_development_dependency 'omniauth-openid',     '~> 1.0.0'
  s.add_development_dependency 'capybara',            '~> 2.2.0'
  s.add_development_dependency 'factory_girl_rails',  '~> 4.3.0'
  s.add_development_dependency 'database_cleaner',    '~> 1.2.0'
  s.add_development_dependency 'cucumber-rails',      '~> 1.4.0'
  s.add_development_dependency 'simplecov',           '~> 0.8.2'
  s.add_development_dependency 'coveralls',           '~> 0.7.0'
end
