module ProposalsHelper
  def proposals_sort_link(label,field)
    opts = {:sort => field}
    opts[:dir] = 'desc' if ( field == params[:sort] && params[:dir] != 'desc' )

    link = link_to label, event_proposals_path(@event, opts)
    link += ( params[:dir] == 'desc' ? ' &or;' : ' &and;' ) if field == params[:sort]
    
    link
  end
end
