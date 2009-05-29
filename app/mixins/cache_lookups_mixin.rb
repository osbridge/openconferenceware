# = CacheLookupsMixin
#
# A mixin that provides simple caching for ActiveRecord models. It's best used
# for models that have relatively few records (less than a thousand) and are
# updated infrequently (less than once per second).
#
# == Example of usage
#
# Setup lookups for Thing:
#
#   class Thing < ActiveRecord::Base
#     cache_lookups_for :id, :order => :created_at
#     ...
#   end
#
# Return array of things in the order they were created:
#   things = Thing.lookup
#
# Return a particular Thing matching ID 66:
#   thing = Thing.lookup(66)
module CacheLookupsMixin
  def self.included(mixee)
    mixee.send(:extend, ClassMethods)
    mixee.class_eval do
      # ActiveRecord model's attribute to use when asked to lookup a specific
      # item. Defaults to :id.
      cattr_accessor :lookup_key
      self.lookup_key = :id

      # Hash of options passed to ActiveRecord::Base.find when populating the
      # cache. This makes it possible to add :order and filter by :condition.
      cattr_accessor :lookup_opts
      self.lookup_opts = {}
    end
  end

  module ClassMethods
    # Setup the lookup caching system.
    #
    # Arguments:
    # * key: The attribute you'll use as a key for doing lookups.
    # * opts: Options to pass to ActiveRecord::Base.find.
    def cache_lookups_for(key, opts={})
      self.lookup_key = key
      self.lookup_opts = opts
    end

    # Return silo that this class's values will be stored in.
    def lookup_silo_name
      return "#{self.name.gsub('::', '__')}_dict"
    end

    # Return instance from cache matching +key+. If +key+ is undefined, returns
    # array of all instances.
    def lookup(key=nil)
      ### Bypass lookup caching if the following global is true:
      if $cache_lookup_mixin_disable
        if key
          return self.find(:first, :conditions => {self.lookup_key => key})
        else
          return self.find(:all, self.lookup_opts)
        end
      end

      silo = self.lookup_silo_name
      dict = nil
      ActiveRecord::Base.benchmark("Lookup: #{silo}#{key.ergo{'#'+to_s}}") do
        dict = self.fetch_object(silo){
          # FIXME Exceptions within this block are silently swallowed by something. This is bad.
          self.find(:all, self.lookup_opts).inject(Dictionary.new){|s,v| s[v.send(self.lookup_key)] = v; s}
        }
      end
      return key ? dict[key.with{kind_of?(Symbol) ? to_s : self}] : (dict.values || [])
    end

    def expire_cache
      Rails.logger.info("Lookup, expiring: #{self.name}")
      Observist.expire(/#{lookup_silo_name}_.+/)
    end

    def fetch_object(silo, &block)
      self.revive_associations_for(self)
      method = Rails.cache.respond_to?(:fetch_object) ? :fetch_object : :fetch
      return Rails.cache.send(method, silo, &block)
    end

    def revive_associations_for(object)
      if object.kind_of?(ActiveRecord::Base) || object.ancestors.include?(ActiveRecord::Base)
        object.reflect_on_all_associations.each do |association|
          name = association.class_name
          unless object.constants.include?(name)
            name.constantize # This line forces Rails to load this class
          end
        end
      end
    end
  end

end
