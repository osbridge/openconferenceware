module OpenConferenceWare

  # == Schema Information
  #
  # Table name: user_favorites
  #
  #  id          :integer          not null, primary key
  #  user_id     :integer
  #  proposal_id :integer
  #  created_at  :datetime
  #  updated_at  :datetime
  #

  class UserFavorite < OpenConferenceWare::Base
    # Associations
    belongs_to :user
    belongs_to :proposal

    # Validations
    validates_presence_of :user_id
    validates_presence_of :proposal_id

    # Add a favorite. Creates record if needed, else leaves as-is.
    def self.add(user_id, proposal_id)
      return self.find_or_create_by(user_id: user_id, proposal_id: proposal_id)
    end

    # Remove a favorite. Removes record if needed, else does nothing.
    def self.remove(user_id, proposal_id)
      if record = self.find_by_user_id_and_proposal_id(user_id, proposal_id)
        return record.destroy
      else
        return false
      end
    end

    # Return the ids of this +user+'s favorite proposals.
    def self.proposal_ids_for(user)
      return self.where(user_id: user.id).select('proposal_id').map(&:proposal_id)
    end
  end
end
