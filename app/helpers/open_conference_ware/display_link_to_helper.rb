module OpenConferenceWare
  module DisplayLinkToHelper

    # Return a #link_to for a +url+ that's been sanitized by #h, had its text
    # truncated, and optionally has the 'rel="nofollow"' flag set.
    #
    # Options:
    # * maxlength: Maximum length of the displayed URL. Defaults to 64.
    # * nofollow: Include a 'rel="nofollow"' in link to discourage spammers. Defaults to true.
    # * mailto: The URL is an email address and should be rendered as a mailto link.
    # * title: Title to give link, else URL.
    def display_link_to(url, opts={})
      opts.symbolize_keys!.reverse_merge!({
        maxlength: 64,
        nofollow: true,
        mailto: false
      })
      link_to_opts = {}
      link_to_opts[:rel] = "nofollow" if opts[:nofollow]
      truncated_url = truncate(url, length: opts[:maxlength])
      url = "mailto:#{url}" if opts[:mailto];
      return link_to(h(opts[:title] || truncated_url), h(url), link_to_opts)
    end
  end
end
