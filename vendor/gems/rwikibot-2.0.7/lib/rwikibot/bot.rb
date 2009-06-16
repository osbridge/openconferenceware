# This is a framework upon which to create MediaWiki Bots. It provides a set
# of methods to acccess MediaWiki's API and return information in various
# forms, depending on the type of information returned. By abstracting these
# methods into a Bot object, cleaner script code can be written later.
# Furthermore, it facilitates the updating of the API without breaking old
# bots. Last, but not least, its good to abstract. #
#
# Author:: Eddie Roger (mailto:eddieroger@gmail.com)
# Copyright:: Copyright (c) 2008 Eddie Roger
# License:: GNU/GPL 2.0

#This is the main bot object. The goal is to represent every API method in
#some form here, and then write seperate, cleaner scripts in individual bot
#files utilizing this framework. Basically, this is an include at best.
module RWikiBot
  class Bot

    include RWikiBot::Errors
    include RWikiBot::Utilities
    include RWikiBot::Pages

    attr_reader :config

    # Creates a new Bot object.
    #
    # Arugments
    # * username - Name to use when logging in to mediawiki API.
    # * password - Password to use when logging in to mediawiki API.
    # * api_path - URL of MediaWiki API to connect to.
    # * domain - Domain name for authentication purposes. You may need this if your wiki is using something like the LDAP Authentication extension.
    # * login - Perform login as part of Bot initialization?
    def initialize(username='rwikibot', password='', api_path='http://www.rwikibot.net/wiki/api.php', domain='', login=false)
      @config = Hash.new

      @config = {
       'username'     => username,
       'password'     => password,
       'api_path'     => api_path,
       'domain'       => domain,
       'cookies'      => "",
       'logged_in'    => false,
       'uri'          => URI.parse(api_path)
      }
      
      @config['api_version'] = version.to_f

      self.login if login
    end

    # This is the method that will allow the bot to log in to the wiki. Its not
    # always necessary, but bots need to log in to save changes or retrieve
    # watchlists.
    def login
      raise VersionTooLowError unless meets_version_requirement(0,0)

      post_me = {'lgname'=>@config.fetch('username'),'lgpassword'=>@config.fetch('password')}
      if @config.has_key?('domain') && (@config.fetch('domain') != nil)
        post_me['lgdomain'] = @config.fetch('domain')
      end

      login_result = make_request('login', post_me)

      # Now we need to changed some @config stuff, specifically that we're
      # logged in and the variables of that This will also change the
      # make_request, but I'll comment there
      if login_result['result'] == "Success"
        # All lg variables are directly from API and stored in config that way
        @config['logged_in']    = true
        @config['lgusername']   = login_result.fetch('lgusername')
        @config['lguserid']     = login_result.fetch('lguserid')
        @config['lgtoken']      = login_result.fetch('lgtoken')
        @config['_session']     = login_result.fetch('sessionid')
        @config['cookieprefix'] = login_result.fetch('cookieprefix')

        true
      else
        # puts "Error logging in. Error was: "
        raise LoginError, "#{login_result['result']}: #{login_result['details']}"
      end
    end

    # Use Page to create a new page object that you can then manipulate. You
    # could create a page on it's own, but if you do, be _sure_ to pass your bot
    # along with the title, otherwise you won't get access to the super-fun
    # make_request object that is pretty much required.
    def page(title='')
      Page.new(self, title)
    end

    # This will return a list of all pages in a given namespace. It returns a
    # list of pages in with the normalized title and page ID, suitable for usage
    # elsewhere. Accepts all parameters from the API in Hash form. Default is
    # namespace => 0, which is just plain pages. Nothing 'special'.
    def all_pages(options = {})
      raise VersionTooLowError unless meets_version_requirement(1,9) 
      # This will get all pages. Limits vary based on user rights of the Bot. Set to bot.
      post_me = {'list' => 'allpages', 'apnamespace' => '0', 'aplimit' => '5000'}
      post_me.merge!(options)
      allpages_result = make_request('query', post_me)
      allpages_result.fetch('allpages')['p']
    end

    # This method will get the watchlist for the bot's MediaWiki username. This
    # is really onlu useful if you want the bot to watch a specific list of
    # pages, and would require the bot maintainer to login to the wiki as the
    # bot to set the watchlist.
    def watchlist(options = {})
      raise VersionTooLowError unless meets_version_requirement(1,10)
      raise NotLoggedInError unless logged_in?
      post_me = {'list'=>'watchlist'}
      post_me.merge!(options)
      make_request('query', post_me).fetch('watchlist').fetch('item')
    end

    # This method will return Wiki-wide recent changes, almost as if looking at the Special page Recent Changes. But, in this format, a bot can handle it. Also we're using the API. And bots can't read.
    def recent_changes(options = {})
      raise VersionTooLowError unless meets_version_requirement(1,10)
      post_me = {"list" => "recentchanges", 'rclimit' => '5000'}
      post_me.merge!(options)
      make_request('query' , post_me).fetch('recentchanges').fetch('rc')
    end

    # This will reutrn a list of the most recent log events. Useful for bots who
    # want to validate log events, or even just a notify bot that checks for
    # events and sends them off.
    def log_events(options = {})
      raise VersionTooLowError unless meets_version_requirement(1,11)
      post_me = {"list" => "logevents"}
      post_me.merge!(options)
      make_request('query', post_me).fetch('logevents').fetch('item')
    end

    # This is the only meta method. It will return site information. I chose not
    # to allow it to specify, and it will only return all known properties.
    def site_info(siprop='general')
      #raise VersionTooLowError unless meets_version_requirement(1,9)
      post_me = {"meta" => "siteinfo" , "siprop" => siprop}
      siteinfo_result = make_request('query', post_me)
      siprop == 'general' ?
        siteinfo_result.fetch('general') :
        siteinfo_result.fetch('namespaces').fetch('ns')
    end

    # Get information about the current user
    def user_info(uiprop=nil)
      raise VersionTooLowError unless meets_version_requirement(1,11)
      post_me = {"meta" => "userinfo" }
      post_me['uiprop'] =  uiprop unless uiprop.nil?

      make_request('query',post_me).fetch('userinfo')
    end
  end
end