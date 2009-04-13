# = Setup caching
#
# == Filesystem caching
#
# The filesystem will be used by default.
#
# == Memcache caching
#
# To use memcache, you must add configuration lines to your "database.yml" that
# tell the environment what initialization settings to use.
#
# For example, make the "production" use memcache with the "mysite" namespace:
#   production:
#     ...
#     memcache:
#       namespace: mysite

require 'rubygems'
require 'erb'
require 'yaml'

class RailsCacheConfigurator
  def self.apply(rails_config)
    # Parse "database.yml". Wish ActiveRecord::Base.configurations was available within environment.rb.
    database_config = YAML.load(ERB.new(File.read(File.join(RAILS_ROOT, 'config', 'database.yml'))).result)

    # Try to find memcache settings.
    memcache_options = database_config[RAILS_ENV]["memcache"]
    if memcache_options
      # Setup memcache
      rails_config.cache_store = :mem_cache_store, memcache_options
    else
      # Setup filestore
      path = File.join(RAILS_ROOT, "tmp", "cache", RAILS_ENV)
      FileUtils.mkdir_p(path)
      rails_config.cache_store = :file_store, path
    end

    #rails_config.logger.info "cache_configurator: using #{Rails.cache.class.name}"
  end
end
