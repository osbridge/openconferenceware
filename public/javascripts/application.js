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

/*===[ custom functions ]=============================================*/

/*---[ page_spinner ]-------------------------------------------------*/

// Display a big spinner in the middle of the page.
function page_spinner_start() {
  $('#page_spinner').show(100);
}

// Hide the big spinner displayed in the middle of the page by`page_spinner_start`.
function page_spinner_stop() {
  $('#page_spinner').hide(100);
}

/*---[ proposal_controls ]--------------------------------------------*/
// AJAXified controls for managing proposals.

// Bind all proposal controls, call this once for on a page using these controls.
function bind_all_proposal_controls() {
  bind_proposal_generic_control('_room_control_html', $('.proposal_room_control'));
  bind_proposal_generic_control('_transition_control_html', $('.proposal_transition_control'));
}

// Bind proposal controls for the given +elements+ (HTML "select" nodes),
// and replace each control if the server sends new HTML that has data in the
// +replace_from+ field of the JSON hash response.
function bind_proposal_generic_control(replace_from, elements) {
  elements.removeAttr("disabled").change(function(event) {
    target = $(this);
    $e = event; $t = target;

    event.preventDefault();
    name = target.attr('name');
    value = target.attr('value');
    proposal_id = target.attr('x_proposal_id');
    format = 'json';
    url = '/proposals/'+proposal_id+'.'+format;
    container = target.parent().parent();
    $k = container;

    $.ajax({
      'type': 'PUT',
      'url': url,
      'data': 'authenticity_token='+window._token+'&'+name+'='+value,
      'dataType': format,
      'beforeSend': function(request) {
        target.attr('disabled', true);
        page_spinner_start();
      },
      'complete': function (XMLHttpRequest, textStatus) {
        page_spinner_stop();
        target.removeAttr('disabled');
      },
      'success': function (data, textStatus) {
        $f = replace_from;
        $d = data;
        if (data && data[replace_from]) {
          target.unbind();
          container.html(data[replace_from]);
          bind_proposal_generic_control(replace_from, container.children().children());
        }
      }
    });

    return false;
  });
}

/*===[ fin ]==========================================================*/
