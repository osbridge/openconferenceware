module OpenConferenceWare
  module ProposalsHelper
    # Return link with a +label+ for sorting records by +field+. The optional
    # +kind+ (e.g., :sessions or :proposals) determines what URLs to generate, if
    # one isn't specified, then the @kind instance variable will be used.
    def sort_link_for(label, field, kind=nil)
      kind ||= @kind

      opts = {sort: field}
      opts[:dir] = 'desc' if ( field == params[:sort] && params[:dir] != 'desc' )

      link = link_to(label, self.send("event_#{kind}_path", @event, opts))
      link += ( params[:dir] == 'desc' ? ' &or;' : ' &and;' ).html_safe if field == params[:sort]

      return link
    end

    # Return a link path for the given +object+. The optional +kind+ (e.g.,
    # :sessions or :proposals) determines what kind of links to make, if one
    # isn't specified, then the @kind instance variable will be used.
    def record_path(object, kind=nil)
      kind ||= @kind
      raise ArgumentError, "No kind or @kind specified" unless kind
      kind = kind.to_s.singularize
      return self.send("#{kind}_path", object)
    end

    # Return a link path for the collection. The optional +kind+ (e.g.,
    # :sessions or :proposals) determines what kind of links to make, if one
    # isn't specified, then the @kind instance variable will be used.
    def records_path(kind=nil)
      kind = (kind || @kind).to_s.pluralize
      return self.send("event_#{kind}_path", @event)
    end

    # Return a path to the next proposal after +proposal+. Or none if none.
    def next_proposal_path_from(proposal)
      if next_proposal = proposal.next_proposal
        return proposal_path(next_proposal)
      else
        return nil
      end
    end

    # Return a path to the previous proposal after +proposal+. Or none if none.
    def previous_proposal_path_from(proposal)
      if previous_proposal = proposal.previous_proposal
        return proposal_path(previous_proposal)
      else
        return nil
      end
    end
  end
end
