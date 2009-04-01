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

/*---[ data structure conveniences ]----------------------------------*/

// Return an array of keys in +hash+. Example:
//  hash_keys({'foo': 'bar', 'baz': 'qux'}); // ['foo', 'baz']
function hash_keys(hash) {
  array = new Array();
  for (key in hash) {
    array.push(key);
  }
  return array;
}

// Return hash where each key is an element of the +array+. Example:
//    array_to_hash(['foo', 'bar']); // {'foo': true, 'bar': true}
function array_to_hash(array) {
  hash = new Array();
  for (i in array) {
    hash[array[i]] = true;
  }
  return hash;
}

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
  bind_proposal_generic_control('room', null);
  bind_proposal_generic_control('transition', null);
}

// Bind AJAX controls for manipulate a proposal's values.
//
// Arguments:
// * kind: The kind of the controls, e.g., "room" or "transition". Required.
// * elements: Elements to bind. Optional, if null will bind to all appropriate controls on page.
function bind_proposal_generic_control(kind, elements) {
  if (! elements) {
    elements = $('.proposal_'+kind+'_control');
  }
  elements.removeAttr('disabled').change(function(event) {
    target = $(this);
    $e = event; $t = target; $k = kind;

    event.preventDefault();
    name = target.attr('name');
    value = target.attr('value');
    proposal_id = target.attr('x_proposal_id');
    format = 'json';
    url = '/proposals/'+proposal_id+'.'+format;

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
        $d = data;
        data_html_field = '_'+kind+'_control_html';
        if (data && data[data_html_field]) {
          // Extact the "option" elements from the JSON repsone's HTML and update the "select" element.
          matcher = new RegExp('(<option[\\s\\S]+</option>)', 'gi').exec(data[data_html_field]);
          if (matcher) {
            target.html(matcher[1]);
          }
        }
      }
    });

    return false;
  });
}
/*
event = $e;
target = $t;
kind = $k;
data = $d;
*/

/*===[ fin ]==========================================================*/
