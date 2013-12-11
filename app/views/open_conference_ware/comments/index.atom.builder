atom_feed() do |feed|
  feed.title("#{OpenConferenceWare.organization}: Presentation Proposal Comments")
  feed.updated(@comments.blank? ? Time.at(0) : @comments.first.created_at)
  feed.subtitle("Administrator-only feed of comments on Ignite proposals.")

  @comments.each do |comment|
    proposal = comment.proposal
    next unless comment.created_at
    next unless proposal
    feed.entry(comment, :created => comment.created_at, :updated => comment.created_at, :url => proposal_url(proposal)) do |entry|
      entry.title(h("Re: #{proposal.title} by #{proposal.presenter}"))
      entry.author do |author|
        author.name(h(comment.email))
      end
      entry.content(<<-HERE, :type => 'html')
<div>
  <b>#{h(comment.email)}</b>:
  <p>
    #{preserve_formatting_of(comment.message)}
  </p>
</div>
      HERE
    end
  end
end
