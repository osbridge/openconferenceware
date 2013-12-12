module OpenConferenceWare

  # == Schema Information
  #
  # Table name: selector_votes
  #
  #  id          :integer          not null, primary key
  #  user_id     :integer          not null
  #  proposal_id :integer          not null
  #  rating      :integer          not null
  #  comment     :text
  #

  class SelectorVote < OpenConferenceWare::Base
    belongs_to :user
    belongs_to :proposal

    validates_presence_of :user
    validates_presence_of :proposal
    validates_presence_of :rating
  end
end
