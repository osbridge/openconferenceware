module OpenConferenceWare
  class Engine < ::Rails::Engine
    isolate_namespace OpenConferenceWare

    config.autoload_paths += [
      root.join('app','mixins').to_s,
      root.join('app','observers').to_s,
      root.join('lib').to_s
    ]

    initializer "open_conference_ware.assets.precompile" do |app|
      app.config.assets.precompile += %w(ie.css)
    end

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
