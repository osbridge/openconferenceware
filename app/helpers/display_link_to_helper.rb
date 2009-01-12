module DisplayLinkToHelper
  # Return a #link_to for a +url+ that's been sanitized by #h, had its text
  # truncated, and optionally has the 'rel="nofollow"' flag set.
  #
  # Options:
  # * :maxlength => Maximum length of the displayed URL. Defaults to 64.
  # * :nofollow => Include a 'rel="nofollow"' in link to discourage spammers. Defaults to true.
  def display_link_to(url, opts={})
    opts.symbolize_keys!.reverse_merge!({
      :maxlength => 64,
      :nofollow => true,
    })
    link_to_opts = opts[:nofollow] ? {:rel => "nofollow"} : {}
    return link_to(truncate(h(url), opts[:maxlength]), link_to_opts)
  end
end
