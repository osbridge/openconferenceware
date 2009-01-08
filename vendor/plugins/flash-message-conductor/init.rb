# Include hook code here
require File.dirname(__FILE__) + '/lib/flash_message_conductor'

ActionController::Base.send( :include, PlanetArgon::FlashMessageConductor::ControllerHelpers )
ActionView::Base.send( :include, PlanetArgon::FlashMessageConductor::ViewHelpers )


