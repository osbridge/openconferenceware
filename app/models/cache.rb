# = Cache
#
# This class provides a central place to interact with the Rails cache, and
# provides methods to find out if caching is ::enabled?, ::fetch arbitrary
# objects from the cache (because many cache drivers don't implement this),
# and ::expire the cache.
class Cache

  # Should caching be enabled If the "perform_caching" Rails environment
  # configuration setting is enabled, default to using cache.
  #
  # You can force caching on or off using the CACHE environmental
  # variable, e.g. activate with:
  #
  #   CACHE=1 ./script/server
  def self.enabled?
    if Rails.configuration.action_controller.perform_caching
      return ENV['CACHE'] != '0'
    else
      return ENV['CACHE'] == '1'
    end
  end

  # Return the object associated with the string +key+. If caching is disabled
  # or the object isn't in the cache, call the +block+ to yield it.
  def self.fetch(key, &block)
    if self.enabled?
      method = Rails.cache.respond_to?(:fetch_object) ? :fetch_object : :fetch
      return Rails.cache.send(method, key, &block)
    else
      return block.call
    end
  end

  # Expire the cache.
  def self.expire(*args)
    case Rails.cache
    when ActiveSupport::Cache::MemCacheStore
      Rails.cache.instance_variable_get(:@data).flush_all
    when ActiveSupport::Cache::FileStore
      Rails.cache.delete_matched(//) rescue nil
    else
      raise NotImplementedError, "Don't know how to expire cache: #{Rails.cache.class.name}"
    end
  end

end
