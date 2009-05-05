# Workaround to make ruby-openid work with Passenger, because these two don't always cooperate.
# http://groups.google.com/group/phusion-passenger/browse_thread/thread/30b8996f8a1b11f0/ba4cc76a5a08c37d?                   @@@ hl=en&lnk=gst&q=openid#ba4cc76a5a08c37d
OpenID::Util.logger = RAILS_DEFAULT_LOGGER
