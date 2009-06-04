namespace :db do
  def mysql_credentials_for(struct)
    string = "--user='#{struct.username}' --password='#{struct.password}' '#{struct.database}'"
    string << " --host='#{struct.host}'" if struct.host
    return string
  end

  namespace :raw do
    desc "Dump database to FILE or name of RAILS_ENV"
    task :dump do
      verbose(true) unless Rake.application.options.silent

      require "lib/database_yml_reader"
      struct = DatabaseYmlReader.read
      target = ENV['FILE'] || "#{File.basename(Dir.pwd)}.sql"
      adapter = struct.adapter

      case adapter
      when "sqlite3"
        source = struct.database
        sh "sqlite3 #{source} '.dump' > #{target}"
      when "mysql"
        sh "mysqldump --add-locks --create-options --disable-keys --extended-insert --quick --set-charset #{mysql_credentials_for(struct)} > #{target}.tmp && mv #{target}.tmp #{target}"
      else
        raise ArgumentError, "Unknown database adapter: #{adapter}"
      end
    end

    desc "Restore database from FILE"
    task :restore do
      verbose(true) unless Rake.application.options.silent

      source = ENV['FILE']
      raise ArgumentError, "No FILE argument specified to restore from." unless source

      require "lib/database_yml_reader"
      struct = DatabaseYmlReader.read
      adapter = struct.adapter

      case adapter
      when "sqlite3"
        target = struct.database
        mv target, "#{target}.old" if File.exist?(target)
        sh "sqlite3 #{target} < #{source}"
      when "mysql"
        sh "mysql #{mysql_credentials_for(struct)} < #{source}"
      else
        raise ArgumentError, "Unknown database adapter: #{adapter}"
      end

      Rake::Task["clear"].invoke
    end
  end
end
