module OpenConferenceWare
  # Methods added to this helper will be available to all templates in the application.
  module ApplicationHelper
    FLASH_KEY_TRANSLATION = {
      "notice" => "info",
      "failure" => "danger",
      "success" => "success"
    }
    def notice
      unless flash.blank?
        flash.keys.map do |key|
          content_tag("div", flash[key], class: "alert alert-#{key} alert-#{FLASH_KEY_TRANSLATION[key.to_s]}")
        end.join("\n").html_safe
      end
    end

    def preserve_formatting_of(text)
      content_tag("div", simple_format(escape_once(text)), class: :compressed)
    end

    def inline_button_to(*args)
      html = button_to(*args)
      html.gsub!(/<div>(.*)/, '<div class="inlined">\1')
      html.gsub!(/class="button-to"/m, 'class="button-to inlined"\1')
      html
    end

    # Add the +html+ to the stylesheets of the layout. Example:
    #   <%= add_stylesheet(stylesheet_link_tag "custom") %>
    def add_stylesheet(html)
      content_for :stylesheets, html
    end

    # Add the +html+ to the javascripts portion of the layout. Example:
    #   <%= add_javascripts(javascript_include_tag "application") %>
    def add_javascript(html)
      content_for :scripts, html
    end

    # Indents a block of code to a specified minimum indent level.
    def indent_block(string, level=0)
      lines = Array(string)
      common_space = lines.map{|line| line.length - line.lstrip.length}.min
      Array(string).map{ |line| ('  ' * level) + line[common_space..-1] }.join.html_safe
    end

    # Exposes a value as a property of the JavaScript 'app' object.
    #   Example:
    #     <% expose_to_js :current_user_id, current_user.id %>
    #     <script> alert(app.current_user_id); </script>
    #
    def expose_to_js(key, value)
      raise(ArgumentError, "key must be a symbol") unless key.is_a?(Symbol)
      value = "'#{value}'" unless value.is_a?(Integer) || true == value || false == value
      content_for :javascript_expose_values, "app.#{key.to_s} = #{value};\n".html_safe
    end

    # Enqueues the given javascript code to run once the DOM is ready.
    def run_when_dom_is_ready(javascript)
      content_for :javascript_on_ready, (javascript + "\n").html_safe
    end

    #---[ Menu navigation ]-------------------------------------------------

    # Is the navigation item the currently viewed page? E.g., if the navigation is :sessions, is the :subnav also :sessions.
    def nav_current_page_item?
      return(nav_kind == subnav_kind)
    end

    # Is the current action related to proposals?
    def proposal_related_action?
      return controller.kind_of?(ProposalsController) && ! ProposalsController::SESSION_RELATED_ACTIONS.include?(action_name)
    end

    # Is the current action related to sessions?
    def session_related_action?
      return (controller.kind_of?(EventsController) && action_name == "speakers") || controller.kind_of?(ProposalsController) && ProposalsController::SESSION_RELATED_ACTIONS.include?(action_name)
      # TODO Make this logic clearer and the menu system less crazy.
    end

    def nav_event
      @nav_event ||= unless assigned_event.try(:new_record?)
                      assigned_event.try(:parent_or_self)
                    end
    end


    # Main navigation to display.
    def nav_kind(event=nil)
      event ||= @event
      if event && event.proposal_status_published?
        return :sessions
      else
        return :proposals
      end
    end

    # Main navigation path to use.
    def nav_path(event=nil)
      event ||= @event
      return self.send("event_#{nav_kind(event)}_path", event)
    end

    # Main navigation title.
    def nav_title(event=nil)
      event ||= @event
      return self.nav_kind(event).to_s.titleize
    end

    # Subnavigation to display.
    def subnav_kind
      if @event
        if @event.proposal_status_published?
          proposal_related_action? ? :proposals : :sessions
        else
          session_related_action? ? :sessions : :proposals
        end
      else
        :proposals
      end
    end

    # Subnavigation path.
    def subnav_path
      return self.send("#{subnav_kind}_path")
    end

    # Subnavigation title.
    def subnav_title
      return self.subnav_kind.to_s.titleize
    end

    # Should this event be flagged as active in the HTML/CSS header?
    def flag_event_as_active?(event)
      return @event ?
        event == @event.parent_or_self :
        true
    end

    # Should the "submit a proposal" link be shown?
    def display_submit_proposal_link?
      assigned_event.try(:accepting_proposals?) && !(controller.controller_name == 'proposals' && action_name == 'new')
    end

    #---[ Assigned events ]-------------------------------------------------

    # Return event assigned to this request, may be nil.
    def assigned_event
      return @event
    end

    # Return array of events assigned to this request, may be empty.
    def assigned_events
      return @events || []
    end

    # Return array of non-child events assigned to this request.
    def assigned_nonchild_events
      return self.assigned_events.compact.uniq.reject(&:parent_id)
    end

    # Return array of non-child events assigned to this request sorted by end-date.
    def assigned_nonchild_events_by_date
      return self.assigned_nonchild_events.sort_by{|event| event.end_date.try(:to_i) || 0}
    end
  end
end
