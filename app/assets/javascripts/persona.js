function personaLogin() {
  navigator.id.get(function(assertion) {
    if (assertion) {
      $('#persona_form input[name=assertion]').val(assertion);
      $('#persona_form').submit();
    } else {
      window.location = "#{failure_path}"
    }
  });
}
