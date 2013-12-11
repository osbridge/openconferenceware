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
