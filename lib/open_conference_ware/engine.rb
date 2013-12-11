module OpenConferenceWare
  class Engine < ::Rails::Engine
    isolate_namespace OpenConferenceWare

    config.autoload_paths += [
      root.join('app','mixins').to_s,
      root.join('app','observers').to_s,
      root.join('lib').to_s
    ]

    # Activate observers that should always be running.
    config.active_record.observers = "OpenConferenceWare::CacheWatcher"

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

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

  end
end
