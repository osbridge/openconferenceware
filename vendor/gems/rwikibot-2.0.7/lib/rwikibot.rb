$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# ruby requires  
require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'

# gem requires
require 'xmlsimple'
require 'deep_merge' # New in 2.0!

require 'rwikibot/errors'
require 'rwikibot/utilities'
require 'rwikibot/pages'
require 'rwikibot/bot'

module RWikiBot
  VERSION = '0.0.1'
end

# I'm never happy with good enough, and when it comes to my hashes, I like to see the members of it. So I changed the hash to_s. Overriding method makes me happy.
class Hash
  def to_s
    elements = self.collect{ |key, value| "#{key} => #{value}" }
    "{#{elements * ', '}}"
  end
end