module FocusHelper

  # Focus the form input on the +target+ element.
  def focus(target)
    # # Plain JavaScript
    #     content_for :javascript, <<-HERE
    # document.getElementById('#{target}').focus();
    #     HERE

    # jQuery
    run_when_dom_is_ready "$('##{target.to_s}').focus();"
  end

end
