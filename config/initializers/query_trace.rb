# Enable the QueryTrace plugin that shows where each database query is coming
# from.
#
# To use this, install the query_trace plugin into 'vendor/plugins_optional'
# and put any value into the QUERYTRACE environmental variable, e.g.:
#
#   QUERYTRACE=1 ./script/server
if ENV['QUERYTRACE']
  Rails.logger.warn("QueryTrace plugin activated from config/environment.rb")
  $LOAD_PATH.unshift "#{RAILS_ROOT}/vendor/plugins_optional/query_trace/lib"
  require "#{RAILS_ROOT}/vendor/plugins_optional/query_trace/init"
end
