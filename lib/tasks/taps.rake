# FIXME MySQL can't import SQLite data because it won't honor its keys

namespace :taps do
  # Return a DBI URI string similar to: postgres://dbuser:dbpassword@localhost/dbname 
  def database_yml_to_dbi_uri
    #IK# source = ActiveRecord::Base.configurations[RAILS_ENV]
    source = YAML.load(ERB.new(File.read(File.join(RAILS_ROOT, 'config', 'database.yml'))).result)[RAILS_ENV]
    target = ""
    target << "#{source['adapter'].gsub('sqlite3', 'sqlite')}://"
    unless source['username'].blank?
      target << "#{source['username']}"
      target << ":#{source['password']}" unless source['password'].blank?
      target << "@"
    end
    if source['hostname'].blank?
      target << "localhost/" if source['adapter'] == "mysql" # FIXME How to specify socket?!
    else
      target << "#{source['host']}"
      target << ":#{source['port']}" unless source['port'].blank?
      target << "/"
    end
    target << "#{source['database']}"

    # FIXME MySQL relies on this, yet taps fails if this is defined
    #target << "?encoding=#{source['encoding']}" unless source['encoding'].blank?
    return target
  end

  def tapsuser
    ENV['TAPSUSER'] || 'user'
  end

  def tapspass
    ENV['TAPSPASS'] || 'pass'
  end

  def tapsurl
    ENV['TAPSURL'] || 'http://user:pass@localhost:5000'
  end

  desc "Start a taps data migration server"
  task :serve do
    sh "taps server #{database_yml_to_dbi_uri} #{tapsuser} #{tapspass}"
  end

  desc "Pull from a taps data migration server"
  task :pull do
    sh "taps pull #{database_yml_to_dbi_uri} #{tapsurl}"
  end

  desc "Push to a taps data migration server"
  task :push do
    sh "taps push #{database_yml_to_dbi_uri} #{tapsurl}"
  end
end
