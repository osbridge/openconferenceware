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

  def include_fckeditor
    return if defined?(@fckeditor_included) and @fckeditor_included
    content_for(:javascript, <<-HERE)
</script>

<script type="text/javascript" src="/fckeditor/fckeditor.js">
</script>

<script type="text/javascript">
  function fckeditor(field_name) {
    var oFCKeditor = new FCKeditor(field_name, '100%', '300') ;
    oFCKeditor.Config["CustomConfigurationsPath"] = "/fckeditor_myconfig.js";
    oFCKeditor.ReplaceTextarea() ;
  }
    HERE
  end

  def fckeditor_for(field_name)
    include_fckeditor
    link_to_function("WYSIWYG editor", "fckeditor('#{field_name}')", :class => :editable)
  end
end
