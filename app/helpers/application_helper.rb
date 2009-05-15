# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def notice
    # XXX Replace with flash conductor plugin?
    unless flash.blank?
      content_tag("div", :id => "flash", :class => "flash") do
        flash.keys.map do |key|
          content_tag("p", flash[key], :class => key)
        end.join("\n")
      end
    end
  end

  def preserve_formatting_of(text)
    content_tag("div", simple_format(escape_once(text)), :class => :compressed)
  end

  def inline_button_to(*args)
    html = button_to(*args)
    html.gsub!(/<div>(.*)/, '<div class="inlined">\1')
    html.gsub!(/class="button-to"/m, 'class="button-to inlined"\1')
    html
  end

  def include_jwysiwyg
    return if defined?(@jwysiwyg_included) && @jwysiwyg_included
    content_for(:stylesheets, stylesheet_link_tag("jquery.wysiwyg.css"))
    content_for(:scripts,javascript_include_tag("jquery.wysiwyg.pack.js") + <<-HERE
    <script type="text/javascript">
      /*<![CDATA[*/
      $(function()
      {
          $('textarea.rich').wysiwyg({
            controls: {
              separator00: { visible: true },
              justifyLeft: { visible: true },
              justifyCenter: { visible: true },
              justifyRight: { visible: true },
              separator04: { visible: true },
              insertOrderedList: { visible: true },
              insertUnorderedList: { visible: true },
              html: { visible: true }
            }
          });
      });
      /*]]>*/
    </script>
    HERE
    )
    @jwysiwyg_included = true
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

  # Include a jQuery $(document).ready() function that calls the given +javascript+ code.
  def run_when_jquery_is_ready(javascript)
    content_for :javascript, <<-HERE
      $(document).ready(function() {
        #{javascript};
      });
    HERE
  end

  # Is the navigation item the currently viewed page? E.g., if the navigation is :sessions, is the :subnav also :sessions.
  def nav_current_page_item?
    return(nav_kind == subnav_kind)
  end

  # Is the current action related to proposals?
  def proposal_related_action?
    return controller.kind_of?(ProposalsController) && ! ["sessions_index", "session_show", "schedule"].include?(action_name)
  end

  # Is the current action related to sessions?
  def session_related_action?
    return controller.kind_of?(ProposalsController) && ["sessions_index", "session_show", "schedule"].include?(action_name)
  end

  # Main navigation to display.
  def nav_kind
    if @event && @event.proposal_status_published?
      return :sessions
    else
      return :proposals
    end
  end

  # Main navigation path to use.
  def nav_path
    return self.send("#{nav_kind}_path")
  end

  # Main navigation title.
  def nav_title
    return self.nav_kind.to_s.titleize
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
end
