# = CacheWatcher
#
# Watches for changes in models and expires the cache.
class CacheWatcher < ActiveRecord::Observer
  # Watch for changes in these classes:
  observe \
    Comment,
    Event,
    Proposal,
    ProposalsUser,
    Room,
    ScheduleItem,
    SessionType,
    Snippet,
    Track,
    User,
    UserFavorite

  # Expire the cache
  def self.expire(*args)
    Rails.logger.info("CacheWatcher: expiring cache")
    Cache.expire(*args)
  end

  def expire(*args)
    self.class.expire(*args)
  end

  # Expire the cache when these triggers are called on a record
  alias_method :after_save,     :expire
  alias_method :after_destroy,  :expire
  alias_method :after_rollback, :expire
end
