
jQuery.noConflict();

if (typeof K2 == 'undefined') var K2 = {};

K2.debug = false;

K2.ajaxGet = function(url, data, complete_fn) {
	jQuery.ajax({
		url:		url,
		data:		data,

		error: function(request) {
			jQuery('#notices')
				.show()
				.append('<p class="alert">Error ' + request.status + ': ' + request.statusText + '</p>');
		},

		success: function() {
			jQuery('#notices').hide().html();
		},

		complete: function(request) {

			// Disable obtrusive document.write
			document.write = function(str) {};

			if ( K2.debug ) {
				console.log(request);
			}

			if ( complete_fn ) {
				complete_fn( request.responseText );
			}

			// Lightbox v2.03.3 - Adds new images to lightbox
			if (typeof myLightbox != "undefined" && myLightbox instanceof Lightbox && myLightbox.updateImageList) {
				myLightbox.updateImageList();
			}
		}
	});
}



function OnLoadUtils() {
	jQuery('#comment-personaldetails').hide();
	jQuery('#showinfo').show();
	jQuery('#hideinfo').hide();
};

function ShowUtils() {
	jQuery('#comment-personaldetails').slideDown();
	jQuery('#showinfo').hide();
	jQuery('#hideinfo').show();
};

function HideUtils() {
	jQuery('#comment-personaldetails').slideUp();
	jQuery('#showinfo').show();
	jQuery('#hideinfo').hide();
};


// Manipulation of cookies (credit: http://www.webreference.com/js/column8/functions.html)
function setCookie(name, value, expires, path, domain, secure) {
  var curCookie = name + "=" + escape(value) +
      ((expires) ? "; expires=" + expires.toGMTString() : "") +
      ((path) ? "; path=" + path : "") +
      ((domain) ? "; domain=" + domain : "") +
      ((secure) ? "; secure" : "");
  document.cookie = curCookie;
};

function getCookie(name) {
  var dc = document.cookie;
  var prefix = name + "=";
  var begin = dc.indexOf("; " + prefix);
  if (begin == -1) {
    begin = dc.indexOf(prefix);
    if (begin != 0) return null;
  } else
    begin += 2;
  var end = document.cookie.indexOf(";", begin);
  if (end == -1)
    end = dc.length;
  return unescape(dc.substring(begin + prefix.length, end));
};

function deleteCookie(name, path, domain) {
  if (getCookie(name)) {
    document.cookie = name + "=" +
    ((path) ? "; path=" + path : "") +
    ((domain) ? "; domain=" + domain : "") +
    "; expires=Thu, 01-Jan-70 00:00:01 GMT";
  }
};


/* Fix the position of an element when it is about to be scrolled off-screen */
function smartPosition(obj) {
	// Detect if content is being scroll offscreen.
	if ( (document.documentElement.scrollTop || document.body.scrollTop) >= jQuery(obj).offset().top) {
		jQuery('body').addClass('smartposition');
	} else {
		jQuery('body').removeClass('smartposition');
	}
};


// Set the number of columns based on window size and maximum set by K2 Options
function dynamicColumns() {
	var window_width = jQuery(window).width();

	if (K2.columns >= 3 && window_width >= K2.layoutWidths[2]) {
		jQuery('body').removeClass('columns-one columns-two').addClass('columns-three');
	} else if (K2.columns >= 2 && window_width >= K2.layoutWidths[1]) {
		jQuery('body').removeClass('columns-one columns-three').addClass('columns-two');
	} else {
		jQuery('body').removeClass('columns-two columns-three').addClass('columns-one');
	}
};
