# Sets up unprefixed shortcuts for namespaced open_conference_ware_*
# fixtures, so that specs can still call users(:quentin) instead of
# open_conference_ware_users(:quentin)

module FixtureShortcuts
  Dir.glob(OpenConferenceWare::Engine.root.join('spec', 'fixtures', 'open_conference_ware_*.yml')).each do |f|
    f = File.basename(f, '.yml')

    define_method f.sub('open_conference_ware_','') do |*args|
      send(f, *args)
    end
  end
end

RSpec.configure do |c|
  c.include FixtureShortcuts
end
