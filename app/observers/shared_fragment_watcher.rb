# = SharedFragmentWatcher
#
# Watches for changes that will affect the shared fragments and renders
# them as needed.
class SharedFragmentWatcher < ActiveRecord::Observer
  # Watch for changes in these classes:
  observe :event

  # Create or update the shared fragments
  def self.render(*args)
    Rails.logger.info("SharedFragmentWatcher: rendering shared fragments")
    SharedFragmentHelper.render_shared_fragments
  end

  def render(*args)
    self.class.render(*args)
  end

  # Render shared fragments when these triggers are called on a record
  alias_method :after_save,     :render
  alias_method :after_destroy,  :render
  alias_method :after_rollback, :render
end
