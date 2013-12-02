// Highlight the active menu item. Works by adding an 'active' class to a
// menu item based on the current URL. Status can be reported via 'console.log'
// if the JavaScript interpreter provides one.
function activate_menu_item () {
    var should_log = false;

    var debug = function (message) {
      if(should_log && (typeof console == "object")) console.log('activate_menu_item: ' + message);
    };

    // Names of menu item classes and regexp fragments that activate them:
    var menu_items_and_activation_patterns = [
      ["bofs", "events/.+?bof/.+"],
      ["proposals_or_sessions", "(events/.+?/)?(proposals|sessions)"],
      ["schedule", "events/.+?/schedule"],
      ["speakers", "events/.+?/speakers"]
    ];

    // Get the URL pathname from the browser:
    var pathname = window.location.pathname;
    // Or set a specific one when developing:
    //    var pathname = "/events/2009/speakers";
    var menu_item_matched = null;

    // Match the first pattern:
    for (var i in menu_items_and_activation_patterns) {
      var menu_item = menu_items_and_activation_patterns[i][0];
      var pattern = menu_items_and_activation_patterns[i][1];
      var re = new RegExp("^/" + pattern + "(?:/.*)?$");
      if (pathname.match(re)) {
        menu_item_matched = menu_item;
        debug('Matched menu item "'+menu_item+'" based on pattern: '+ pattern);
        break;
      }
    }

    // Activate the menu item:
    if (menu_item_matched) {
        $('#header .'+menu_item_matched).parent().addClass('active');
    } else {
        debug("No match for pathname: " + pathname);
    }
}

$(document).ready(function () {
  activate_menu_item();
});
