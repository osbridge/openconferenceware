require 'erb'
require 'yaml'
require 'ostruct'
require 'socket'

# = SettingsReader
#
# Returns an OpenStruct object representing settings read from an ERB-parsed
# YAML file.
class SettingsReader
  def self.read(filename)
    return OpenStruct.new(YAML.load(ERB.new(File.read(filename)).result))
  end
end
