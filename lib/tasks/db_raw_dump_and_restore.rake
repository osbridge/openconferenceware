namespace :db do
  desc "Export database to text"
  task :export do
    require 'yaml'
    struct = YAML::load(
      File.read(File.join(RAILS_ROOT, "config", "database.yml")))
    path = struct[RAILS_ENV]["database"]
    sh "sqlite3 #{path} '.dump' > #{RAILS_ENV}.sql"
  end
end
