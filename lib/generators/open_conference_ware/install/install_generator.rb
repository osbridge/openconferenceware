class OpenConferenceWare::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :mount_point,
    type: :string,
    default: "/",
    desc: "The path where OpenConferenceWare should be mounted",
    banner: "MOUNT_POINT (Default: /)"

  def copy_config_initializer
    template "config_initializer.rb", "config/initializers/01_open_conference_ware.rb"
  end

  def copy_omniauth_initializer
    copy_file "omniauth_initializer.rb", "config/initializers/02_omniauth.rb"
  end

  def mount_engine
    route %Q{mount OpenConferenceWare::Engine => "#{mount_point}"}
  end

  def include_engine_seeds
    append_to_file "db/seeds.rb" do
      <<-SEED

# Include OpenConferenceWare's seed data
OpenConferenceWare::Engine.load_seed
      SEED
    end
  end

  def run_setup_rake_task
    rake "open_conference_ware:setup"
  end
end
