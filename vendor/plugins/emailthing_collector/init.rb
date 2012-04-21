# Include hook code here

require File.dirname(__FILE__) +  "/lib/emailthing"
require File.dirname(__FILE__) +  "/lib/emailthing_notifier"
require "net/http"
require "action_mailer"

class ActionMailer::Base
  include Emailthing
  @@emailthing_settings = {
    :api_key => nil
  }
  cattr_accessor :emailthing_settings
end

class ActionController::Base
  def notify_emailthing_of_clicked_links
    EmailthingNotifier.link_clicked(params[:et_id]) if params[:et_id]
  end

end
