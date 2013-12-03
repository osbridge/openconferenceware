/*---[ page_spinner ]-------------------------------------------------*/

// Display a big spinner in the middle of the page.
function page_spinner_start() {
  $(document.createElement("div")).attr('id','page_spinner').text('Working...').prependTo('body').show(100);
}

// Hide the big spinner displayed in the middle of the page by`page_spinner_start`.
function page_spinner_stop() {
  $('#page_spinner').hide(100, function(){ $(this).remove() });
}
