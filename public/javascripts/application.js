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
    if (key) {
      array.push(key);
    }
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
  $(document.createElement("div")).attr('id','page_spinner').text('Working...').prependTo('body').show(100);
}

// Hide the big spinner displayed in the middle of the page by`page_spinner_start`.
function page_spinner_stop() {
  $('#page_spinner').hide(100).remove();
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

/*---[ proposal_mailto ]----------------------------------------------*/

// Return array of email addresses for a given +proposal_id+. Example:
//    addresses_for_manage_proposal_id(129)
function addresses_for_manage_proposal_id(proposal_id) {
  // TODO Why does this next line trigger a "identifier or string for value in attribute selector but found 'X'." where X is the +proposal_id+?
  row = $('.row-for-proposal[x_proposal_id='+proposal_id+']');
  addresses = new Array();
  row.find('.user-email').each(function() {addresses.push(this.value)});
  return addresses;
}

// Update the mailto used to contact presenters. The +is_add+ is true if
// adding, false if removing. The +addresses+ are an array of addresses to
// add or remove.
//    update_manage_proposals_mailto(true, ["bubba@smith.com", "billy.sue@smith.com"])
function update_manage_proposals_mailto(is_add, addresses) {
  element = $('.send-email-link');
  href = element.attr('href');
  prefix = 'mailto:';
  parser = new RegExp('^'+prefix+'(.+)$');
  stripper = new RegExp('bcc=', 'gi');
  matcher = parser.exec(href);
  addresses_hash = matcher ? array_to_hash(matcher[1].replace(stripper, '').split(',')) : [];
  $(addresses).each(function(){
    if (is_add) {
      addresses_hash[this] = true;
    } else {
      delete addresses_hash[this];
    }
  });
  result = prefix+(hash_keys(addresses_hash).map(function(me) {return 'bcc='+me}).join(','));
  element.attr('href', result);
  return result;
}

function bind_manage_proposals_checkboxes() {
  $('.send-email-checkbox').click(function(event) {
    target = $(this); $t = target;
    row = target.parents('.row-for-proposal');
    proposal_id = row.attr('x_proposal_id');
    proposal_addresses = addresses_for_manage_proposal_id(proposal_id);
    update_manage_proposals_mailto(target.attr('checked'), proposal_addresses);
    return true;
  });
}

/*===[ fin ]==========================================================*/
