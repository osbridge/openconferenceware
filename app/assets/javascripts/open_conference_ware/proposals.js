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
        proposal: {
          authenticity_token: app.authenticity_token,
          start_time: {
            date: target.parent().find('select.date').attr('value'),
            hour: target.parent().find('select.hour').attr('value'),
            minute: target.parent().find('select.minute').attr('value')
          }
        }
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
