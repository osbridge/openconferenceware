module OpenConferenceWare
  module ScrollToHelper
    # Scroll the window with jQuery to the target selection.
    #
    # To an id:
    #
    #   <% scroll_to '#event_open_text' %>
    #
    # To a query:
    #   <% scroll_to 'label[for=event_open_text]' %>
    def scroll_to(target)
      run_when_dom_is_ready "$('html,body').animate({scrollTop: $('#{h target.to_s}').offset().top},'slow');"
    end
  end
end
