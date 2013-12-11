require 'open_conference_ware/dependencies'

module OpenConferenceWare
  class Engine < ::Rails::Engine
    isolate_namespace OpenConferenceWare

    config.autoload_paths += [
      root.join('app','mixins').to_s,
      root.join('app','observers').to_s,
      root.join('lib').to_s
    ]

    initializer "open_conference_ware.assets.precompile" do |app|
      # Precompile IE-only assets
      app.config.assets.precompile += ['ie.js']

      # Include vendored image, font, and flash assets when precompiling
      app.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.eot *.svg *.ttf *.woff *.swf)
    end

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
