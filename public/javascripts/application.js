// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/*===[ onload functions ]=============================================*/

// Highlight the flash notification area briefly.
// REQUIRES: jquery-ui.highlight
function pulse_flash() {
  $('.flash, .flash p').effect('highlight', {}, 3000)
}

$(document).ready(function() {
  pulse_flash();
})

/*===[ fin ]==========================================================*/
