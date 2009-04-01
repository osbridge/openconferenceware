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
  
  def schedule_available?
    (@event.proposal_status_published? || admin?) && proposal_start_times? && proposal_statuses? && event_rooms?
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

  def include_jquery_document_ready(javascript, &block)
    content_for :javascript, <<-HERE
$(document).ready(function() {
  #{javascript};
});
    HERE
  end

  def bind_all_proposal_controls_with_javascript
    include_jquery_document_ready('bind_all_proposal_controls();')
  end
end
