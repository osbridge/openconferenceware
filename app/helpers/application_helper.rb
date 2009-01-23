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
          $('textarea.rich').wysiwyg();
      });
      /*]]>*/
    </script>
    HERE
    )
    @jwysiwyg_included = true
  end
end
