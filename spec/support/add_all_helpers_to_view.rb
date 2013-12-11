module AddAllHelpersToView
  HELPER_PATH = OpenConferenceWare::Engine.root.join('app', 'helpers', 'open_conference_ware', '*.rb')
  def _all_helper_modules
    @@_all_helper_modules ||= [
      Dir.glob(HELPER_PATH).map {|f| "OpenConferenceWare::#{File.basename(f, '.rb').camelize}".constantize },
      OpenConferenceWare::Engine.routes.url_helpers
    ].flatten
  end

  def add_all_helpers_to(view)
    _all_helper_modules.each do |helper_module|
      view.extend(helper_module)
      self.class.send(:include, helper_module)
    end
  end
end

RSpec.configure do |c|
  c.include AddAllHelpersToView

  c.before :each, type: :view do
    add_all_helpers_to(view)
  end
end
