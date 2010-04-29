$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'rubygems'
require 'active_record'

begin
  require 'sqlite3'
rescue LoadError
  gem 'sqlite3-ruby'
  retry
end

ActiveRecord::Base.establish_connection({"adapter" => "sqlite3", "database" => 'test.sqlite3'})
begin
  ActiveRecord::Base.connection.execute("drop table mock_records");
  ActiveRecord::Base.connection.execute("drop table foos");
  ActiveRecord::Base.connection.execute("drop table bars");
rescue
end
ActiveRecord::Base.connection.execute("create table mock_records(id int)");
ActiveRecord::Base.connection.execute("create table foos(id int)");
ActiveRecord::Base.connection.execute("create table bars(id int)");

require 'after_commit'
