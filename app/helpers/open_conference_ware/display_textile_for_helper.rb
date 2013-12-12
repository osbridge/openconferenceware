module OpenConferenceWare
  module DisplayTextileForHelper
    def display_textile_for(text)
      return auto_link(textilize(sanitize(text || "")).html_safe, :all, rel: 'nofollow').html_safe
    end

    def display_textile_help_link
      return link_to('Formatting', 'http://redcloth.org/hobix.com/textile/', target: "_blank")
    end
  end
end
