date_time_formats = {
  default: '%m/%d/%Y %I:%M%p',
  date_time12: "%m/%d/%Y %I:%M%p",
  date_time24: "%m/%d/%Y %H:%M",
  date_time_long: "%A, %B %d, %Y %I:%M%p",
}

Time::DATE_FORMATS.merge!(date_time_formats)
Date::DATE_FORMATS.merge!(date_time_formats)
