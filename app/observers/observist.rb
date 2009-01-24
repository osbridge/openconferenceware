class Observist < ActiveRecord::Observer
  observe \
    Proposal,
    Snippet,
    Event,
    Track,
    User

  def self.expire(*args)
    RAILS_DEFAULT_LOGGER.info("Observist: expiring cache")
    # XXX move expiration into models and call their methods if they respond?
    # FIXME Why does the tmp/cache/RAILS_ENV directory vanish periodically, and the delete_matched methods care about this?
    RAILS_CACHE.delete_matched(/proposals?_.+/) rescue nil
    RAILS_CACHE.delete_matched(/snippets?_.+/) rescue nil
    RAILS_CACHE.delete_matched(/events?_.+/) rescue nil
    RAILS_CACHE.delete_matched(/tracks?_.+/) rescue nil
    RAILS_CACHE.delete_matched(/users?_.+/) rescue nil
  end

  def expire(*args)
    self.class.expire
  end

  alias_method :after_save,    :expire
  alias_method :after_destroy, :expire
end
