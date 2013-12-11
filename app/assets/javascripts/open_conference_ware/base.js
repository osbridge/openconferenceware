// Set up jQuery ajax request to include the CSRF token
$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

// app object used to expose rails variables to javascript
var app = new Object;

// Is a user logged in?
function logged_in() {
  return !app.current_user == false;
}
