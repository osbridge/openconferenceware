require 'active_support/cache/file_store'

# FIXME alias_method_chain read/write for memcache compatibility

module ActiveSupport
  module Cache
    class FileStore
      def fetch_object(key, &block)
        unless value = RAILS_CACHE.read(key)
          value = yield
          RAILS_CACHE.write(key, value)
        end
        return value
      end
    end
  end
end
