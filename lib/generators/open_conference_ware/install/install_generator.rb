class OpenConferenceWare::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_config_initializer
    copy_file "config_initializer.rb", "config/initializers/open_conference_ware.rb"
  end

  def run_setup_rake_task
    rake "open_conference_ware:setup"
  end
end
