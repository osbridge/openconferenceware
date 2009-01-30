require 'erb'
require 'yaml'
require 'activesupport'

class RemoteParams
  def self.get
    @params ||= begin
      result = HashWithIndifferentAccess.new(
        YAML::load(
          ERB.new(
            File.read(
              File.join(RAILS_ROOT, "config/remote.yml"))).
          result(binding))
      )
      result[:user_at_host] = "#{result[:user] ? result[:user]+'@' : ''}#{result[:host]}"
      result[:user_at_host_path] = "#{result[:user_at_host]}:#{result[:path]}"
      result
    end
  end
end
