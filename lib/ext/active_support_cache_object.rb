# Monkey patch ActiveSupport::Cache provider to allow caching objects.

module ActiveSupportCacheObject
  def fetch_object(key, &block)
    unless value = Rails.cache.read(key)
      value = yield
      Rails.cache.write(key, value)
    end
    return value
  end
end

require 'active_support/cache/file_store'
unless ActiveSupport::Cache::FileStore.instance_methods.include?("fetch_object")
  ActiveSupport::Cache::FileStore.send(:include, ActiveSupportCacheObject)
end

require 'active_support/cache/mem_cache_store'
unless ActiveSupport::Cache::MemCacheStore.instance_methods.include?("fetch_object")
  ActiveSupport::Cache::MemCacheStore.send(:include, ActiveSupportCacheObject)
end
