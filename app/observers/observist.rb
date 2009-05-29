class Observist < ActiveRecord::Observer
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

  def self.expire(*args)
    pattern = args.first || //
    Rails.logger.info("Observist: expiring cache")
    case Rails.cache
    when ActiveSupport::Cache::MemCacheStore
      Rails.cache.instance_variable_get(:@data).flush_all
    when ActiveSupport::Cache::FileStore
      Rails.cache.delete_matched(pattern) rescue nil
    else
      raise NotImplementedError, "Don't know how to expire cache: #{Rails.cache.class.name}"
    end
  end

  def expire(*args)
    self.class.expire
  end

  alias_method :after_save,    :expire
  alias_method :after_destroy, :expire
end
