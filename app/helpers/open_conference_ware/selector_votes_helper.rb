module OpenConferenceWare
  module SelectorVotesHelper
    def user_votes_count(user, event)
      user.selector_votes.joins(:proposal).where('open_conference_ware_proposals.event_id = ?', event.id).count
    end
  end
end
