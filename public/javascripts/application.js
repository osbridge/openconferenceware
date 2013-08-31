// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// app object used to expose rails variables to javascript
var app = new Object;

/*===[ custom functions ]=============================================*/

function logged_in() {
  return !app.current_user == false;
}

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
  $('#page_spinner').hide(100, function(){ $(this).remove() });
}

/*---[ proposal_controls ]--------------------------------------------*/
// AJAXified controls for managing proposals.

// Bind all proposal controls, call this once for on a page using these controls.
function bind_all_proposal_controls() {
  bind_proposal_generic_control('room', null);
  bind_proposal_generic_control('transition', null);
  bind_proposal_schedule_controls();
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
    url = app.proposals_path + '/' + proposal_id + '.' + format;

    data = { 'authenticity_token': app.authenticity_token };
    data[name] = value;
    $d = data;

    $.ajax({
      'type': 'PUT',
      'url': url,
      'data': data,
      'dataType': format,
      'beforeSend': function(request) {
        target.attr('disabled', true);
        page_spinner_start();
      },
      'complete': function (XMLHttpRequest, textStatus) {
        page_spinner_stop();
        target.removeAttr('disabled');
      },
      'success': function (response, textStatus) {
        $r = response;
        html_field = '_'+kind+'_control_html';
        if (response && response[html_field]) {
          // Extact the "option" elements from the JSON repsone's HTML and update the "select" element.
          var matcher = new RegExp('(<option[\\s\\S]+</option>)', 'gi').exec(response[html_field]);
          if (matcher) {
            target.html(matcher[1]);
          }

          // Hide or unhide the room and schedule controls based on the proposal's state
          var dependent = target.parent().parent().find('.proposal_admin_controls_dependent_on_confirmed_status');
          if (response['proposal_status'] == 'confirmed') {
            dependent.show();
          } else {
            dependent.hide();
          }
        }
      }
    });

    return false;
  });
}

function bind_proposal_schedule_controls() {
  $('.proposal_schedule_control_container select').change(function(event) {
    // Clears all time select elements if any are set to blank.
    target = $(this);

    if(target.attr('selectedIndex')==0) {
      target.parent().find('select').attr('selectedIndex',0);
    }
  }).change(function(event) {
    target = $(this);
    // Submits the schedule form on change if all three select element have values.
    if(target.parent().find('option:selected[value]').get().length == 3) {

      data = {
        'authenticity_token': app.authenticity_token,
        'start_time[date]': target.parent().find('select.date').attr('value'),
        'start_time[hour]': target.parent().find('select.hour').attr('value'),
        'start_time[minute]': target.parent().find('select.minute').attr('value')
      };
      proposal_id = target.parent().attr('id').split('_').pop();
      format = 'json';
      url = app.proposals_path + '/' + proposal_id + '.' + format;

      $.ajax({
        'type': 'PUT',
        'url': url,
        'data': data,
        'dataType': format,
        'beforeSend': function(request) {
          target.parent().find('select').attr('disabled', true);
          page_spinner_start();
        },
        'complete': function (XMLHttpRequest, textStatus) {
          page_spinner_stop();
          target.parent().find('select').removeAttr('disabled');
        }
      });

      return false;
    }
  });

  $('.proposal_schedule_control_container select.hour').change(function(event){
    // If no minute value is set, set minutes to 00 when hour is changed to a non-blank value.
    target = $(this);
    if(target.attr('selectedIndex') != 0) {
      minute_select = target.parent().find('select.minute');
      if(minute_select.attr('selectedIndex') == 0) {
        minute_select.attr('selectedIndex',1).trigger('change');
      }
    }
  });
}

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

// Update the hidden field proposal_ids, used to notify presenters. The +is_add+ is true if
// adding, false if removing.
//    update_manage_proposals_notify_list(true, 123)
function update_manage_proposals_notify_list(is_add, proposal_id) {
  element = $('#accepted_email_proposal_ids, #rejected_email_proposal_ids');
  value = element.attr('value');
  proposal_id_hash = array_to_hash(value.split(','));
  if (is_add) {
    proposal_id_hash[proposal_id] = true;
  } else {
    delete proposal_id_hash[proposal_id];
  }
  result = hash_keys(proposal_id_hash).join(',');
  element.attr('value', result);
  return element;
}

function bind_manage_proposals_checkboxes() {
  $('.send-email-checkbox').click(function(event) {
    target = $(this); $t = target;
    row = target.parents('.row-for-proposal');
    proposal_id = row.attr('x_proposal_id');
    proposal_addresses = addresses_for_manage_proposal_id(proposal_id);
    update_manage_proposals_mailto(target.attr('checked'), proposal_addresses);
    update_manage_proposals_notify_list(target.attr('checked'), proposal_id);
    return true;
  });
}

/*---[ proposals sub lists ]------------------------------------------*/

// Change the UI of the proposal_sub_list so that the proposals are hidden behind a link.
function archive_proposals_sub_list(event_id) {
  var container = $('#sub_list_for_event_'+event_id+' .proposals_sub_list_for_kind_proposals');
  var toggle = container.find('.proposals_sub_list_for_kind_toggle');
  var content = container.find('.proposals_sub_list_for_kind_content');
  toggle.click(function(event) {
    var target = $(this); $t = target;
    var partner = target.parents('.proposals_sub_list_for_kind').find('.proposals_sub_list_for_kind_content');
    target.hide();
    partner.show();
    return false;
  });
  toggle.show();
  content.hide();
}

/*---[ schedule hover ]----------------------------------------------*/

function bind_calendar_items() {
  $('ul.calendar_items li.vevent').hover(
    function() {
      $(this).addClass('hover');
      box = $(this).children('.session_info');

      bottom = $(document).scrollTop() + $(window).height();
      box_bottom = box.offset().top + box.outerHeight();

      if ( box_bottom > bottom ) box.css('top',-(box_bottom - bottom + 10));
      if( !$(this).hasClass('generic_item')) box.css('border-color',$(this).css('background-color'));
      },
    function() {
      $(this).removeClass('hover');
      $(this).children('.session_info').css('top',0);
    }
  )
}



/*---[ user favorites ]----------------------------------------------*/

// Return the proposal_id (e.g., "266") bound to a user favorite control, which
// is a JQuery +element+ object.
var proposal_id_pattern = /^favorite_(\d+)$/;
function proposal_id_for(element) {
  var klasses = element.attr('class').split(' ');
  for (i in klasses) {
    klass = klasses[i];
    var matcher = klass.match(proposal_id_pattern);
    if (matcher) {
      return matcher[1];
    }
  }
  return null;
}

function bind_user_favorite_controls() {
  $('.favorite').each(function() {
      if( !logged_in() ) {
        $(this).addClass('disabled');
      }
    }).click(function(event) {
    target = $(this);

    if( !logged_in() ) {
      alert("You must be logged in to add items to your favorites.");
    } else {
      target.addClass('working');

      mode = target.hasClass('checked') ? 'remove' : 'add';
      proposal_id = proposal_id_for(target);

      $.ajax({
        'type': 'PUT',
        'url': app.favorites_path + '/modify.json',
        'dataType': 'json',
        'data': {
          'authenticity_token': app.authenticity_token,
          'proposal_id': proposal_id,
          'mode': mode
        },
        'complete': function(request,status){
          target.removeClass('working');
        },
        'success': function(data, status) {
          nodes = $('.favorite_'+proposal_id);
          switch(mode) {
          case 'add':
            nodes.addClass('checked');
            break;
          case 'remove':
            nodes.removeClass('checked');
            break;
          }
        },
        'error': function(request, status, error) {
          alert('There was an error! Status: ' + status + ". Error: " + error);
        }
      });
    }
    return false;
  });
}

function populate_user_favorites() {
  if( logged_in() ) {
    $.getJSON( app.favorites_path + '.json?join=1',
      function(data) {
        jQuery.each( data, function(i, proposal_id) {
          $( '.favorite_' + proposal_id ).addClass('checked');
        });
      }
    )
  }
}

/*===[ fin ]==========================================================*/
