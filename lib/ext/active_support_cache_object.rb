# Monkey patch ActiveSupport::Cache provider to allow caching objects.

module ActiveSupportCacheObject
  def write_object(key, object)
    return Rails.cache.write(key, Marshal.dump(object), :raw => true)
  end

  def read_object(key)
    value = Rails.cache.read(key, :raw => true)
    return value ? Marshal.load(value) : value
  end

  def fetch_object(key, &block)
    unless value = read_object(key)
      value = yield
      write_object(key, value)
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
