// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function onloader() {
  pulse_flash();
}

function pulse_flash() {
  var field = $('flash');
  if (field) {
    new Effect.Highlight('flash', {startcolor: '#AFFF70', endcolor: '#FFFFFF', restorecolor: '#FFFFFF'})
  }
}
