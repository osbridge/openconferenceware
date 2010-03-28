class ClearRememberTokensForUsers < ActiveRecord::Migration
  def self.up
    User.update_all('remember_token = NULL, remember_token_expires_at = NULL')
  end

  def self.down
    # No "down" migration possible because "up" removed obsolete data.
  end
end
