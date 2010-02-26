# From http://wiki.github.com/aslakhellesoy/cucumber/fixtures
Before do
  Fixtures.reset_cache
  fixtures_folder = File.join(RAILS_ROOT, 'spec', 'fixtures')
  fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
  Fixtures.create_fixtures(fixtures_folder, fixtures)
end

# Return the boolean for the given string, e.g., "y" is true.
def boolean_for(truth)
  case truth
  when true, /^y/i, /^t/i
    true
  else
    false
  end
end
