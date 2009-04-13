# Monkey patch ActiveSupport::Cache provider to allow caching objects.

module ActiveSupportCacheObject
  def write_object(key, object)
    return RAILS_CACHE.write(key, Marshal.dump(object), :raw => true)
  end

  def read_object(key)
    value = RAILS_CACHE.read(key, :raw => true)
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

# FileStore on Rails 2.1 requires this
require 'active_support/cache/file_store'
unless ActiveSupport::Cache::FileStore.instance_methods.include?("fetch_object")
  ActiveSupport::Cache::FileStore.send(:include, ActiveSupportCacheObject)
end

# MemCacheStore on Rails 2.1 does NOT require this
