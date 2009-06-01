class UserFavorite < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :proposal

  # Validations
  validates_presence_of :user_id
  validates_presence_of :proposal_id

  # Add a favorite. Creates record if needed, else leaves as-is.
  def self.add(user_id, proposal_id)
    return self.find_or_create_by_user_id_and_proposal_id(user_id, proposal_id)
  end

  # Remove a favorite. Removes record if needed, else does nothing.
  def self.remove(user_id, proposal_id)
    if record = self.find_by_user_id_and_proposal_id(user_id, proposal_id)
      return record.destroy
    else
      return false
    end
  end

end
