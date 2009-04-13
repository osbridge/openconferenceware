class Observist < ActiveRecord::Observer
  observe \
    Comment,
    Event,
    Proposal,
    ProposalsUser,
    Room,
    SessionType,
    Snippet,
    Track,
    User

  def self.expire(*args)
    RAILS_DEFAULT_LOGGER.info("Observist: expiring cache")
    # FIXME Why does the tmp/cache/RAILS_ENV directory vanish periodically, and the delete_matched methods care about this?
    RAILS_CACHE.delete_matched(//)
  end

  def expire(*args)
    self.class.expire
  end

  alias_method :after_save,    :expire
  alias_method :after_destroy, :expire
end
