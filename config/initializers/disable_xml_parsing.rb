
# Disable XML parsing for now until we upgrade Rails.
# CVE-2013-0156  See https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ
ActionController::Base.param_parsers.delete(Mime::XML)

