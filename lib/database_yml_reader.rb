# Returns a data structure representing the currently configured database in
# "database.yml" for this "RAILS_ENV".
#
# Examples:
#
#   # Return current database information:
#   struct = DatabaseYmlReader.read
#
#   # Print currently-configured database name:
#   p struct.database
class DatabaseYmlReader
  require 'erb'
  require 'yaml'
  require 'ostruct'

  def self.read
    return OpenStruct.new(
      YAML.load(
        ERB.new(
          File.read(
            File.join(RAILS_ROOT, "config", "database.yml"))).result)[RAILS_ENV])
  end
end
