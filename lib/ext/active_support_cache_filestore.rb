require 'active_support/cache/file_store'

# FIXME alias_method_chain read/write for memcache compatibility

module ActiveSupport
  module Cache
    class FileStore
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
  end
end
