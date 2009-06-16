Gem::Specification.new do |s|
  s.name = %q{rwikibot}
  s.version = "2.0.7"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eddie Roger", ]
  s.date = %q{2009-01-02}
  s.description = %q{A Ruby framework for creating MediaWiki robots.}
  s.email = %q{eddieroger@gmail.com}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ['lib/*.rb', 'test/*']
  s.files = ["CHANGELOG", "README.textile", "Rakefile", "lib/rwikibot.rb","lib/pages.rb","lib/errors.rb", "lib/utilities.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rwikibot.net/wiki}
  s.rdoc_options = ["--main","--inline-source","--force-update", "README.textile"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Creates an abstraction layer between MediaWiki API and Ruby.}
 
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
 
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<deep_merge>, ["> 0.0.0"])
      s.add_runtime_dependency(%q<xml-simple>, ["> 0.0.0"])
    else
      s.add_dependency(%q<deep_merge>, ["> 0.0.0"])
      s.add_dependency(%q<xml-simple>, ["> 0.0.0"])
    end
  else
    s.add_dependency(%q<deep_merge>, ["> 0.0.0"])
    s.add_dependency(%q<xml-simple>, ["> 0.0.0"])
  end
end