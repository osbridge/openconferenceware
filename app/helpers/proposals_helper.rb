module ProposalsHelper
  def proposals_sort_link(label,field)
    opts = {:sort => field}
    opts[:dir] = 'desc' if ( field == params[:sort] && params[:dir] != 'desc' )

    link = link_to label, event_proposals_path(@event, opts)
    link += ( params[:dir] == 'desc' ? ' &or;' : ' &and;' ) if field == params[:sort]

    link
  end

  def state_change_select proposal = nil
    proposal ||= @proposal
    content_tag(:div,
      (content_tag(
        :label, "Change Proposal Status "<<
          "(currently '#{proposal.aasm_current_state.to_s.titleize}')",
        :for => 'proposal_transition'
      ) <<
      content_tag(:div,
        unless proposal.aasm_events_for_current_state.empty?
          select('proposal', 'transition',
            proposal.aasm_events_for_current_state.map{|s|[s.to_s.titleize, s.to_s]},
            :include_blank => true
          )
        else
          %Q~No valid transitions available from status '#{proposal.aasm_current_state}'~
        end
      )
    ))
  end
end
