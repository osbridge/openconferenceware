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
