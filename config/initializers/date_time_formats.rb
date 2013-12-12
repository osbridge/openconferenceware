date_time_formats = {
  ocw_default: '%m/%d/%Y %I:%M%p',
  ocw_date_time12: "%m/%d/%Y %I:%M%p",
  ocw_date_time24: "%m/%d/%Y %H:%M",
  ocw_date_time_long: "%A, %B %d, %Y %I:%M%p",
}

Time::DATE_FORMATS.merge!(date_time_formats)
Date::DATE_FORMATS.merge!(date_time_formats)
