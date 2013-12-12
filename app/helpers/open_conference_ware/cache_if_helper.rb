module OpenConferenceWare
  module CacheIfHelper
    # Caches +block+ in view only if the +condition+ is true.
    # http://skionrails.wordpress.com/2008/05/22/conditional-fragment-caching/
    def cache_if(condition, name={}, &block)
      if condition
        cache(name, &block)
      else
        block.call
      end
    end
  end
end
