module OpenConferenceWare
  # = PageTitleHelper
  #
  # This mixin provides a #page_title helper for easily getting/setting the
  # page's title, and providing a reasonable title if none was set.
  module PageTitleHelper

    # Return string to be used as a page title (e.g., for HTML's TITLE and H1).
    # If +value+ provided, also sets page title. If no page title was set,
    # provides a reasonable simulation based on the controller's name and action.
    def page_title(value=nil)
      @_page_title = value if value
      return(@_page_title || "#{controller.controller_name.humanize}: #{action_name.humanize}")
    end

  end
end
