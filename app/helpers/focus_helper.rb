module FocusHelper

  # Focus the form input on the +target+ element.
  def focus(target)
    # Plain JavaScript
    content_for :javascript, <<-HERE
document.getElementById('#{target}').focus();
    HERE

    # jQuery
#    content_for :javascript, <<-HERE
#$(document).ready(function() {
#  $('##{target.to_s}').focus();
#});
#    HERE
  end

end
