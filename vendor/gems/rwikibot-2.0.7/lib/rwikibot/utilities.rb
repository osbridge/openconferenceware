module RWikiBot
  module Utilities
    include RWikiBot::Errors

    def meets_version_requirement(maj, min)
      major, minor = @config['api_version'].to_s.split('.').collect{ |s| s.to_i }
  #    puts "#{major} > #{maj}"
      (major > maj) || ( (major == maj) && (minor >= min) )
    end # meets_version_requirement

    # Tests to see if a given page title is redirected to another page. Very Ruby.
    def is_redirect?(title)
      post_me = {'titles' => title, 'redirects'=>'', 'prop' => 'info'}
      result = make_request('query', post_me)
      (result['result'] == "Success") && result.has_key?("redirects")
    end

    # A quick (and public) method of checking whether or not we're logged in, since I don't want @config exposed
    def logged_in?
      @config['logged_in']
    end

    # The point of this method is to iterate through an array of hashes, which most of the
    # other methods return, and remove multiple instances of the same wiki page. We're more
    # than often only concerned with the most recent revision, so we'll delete old ones.
    #
    # Hashes don't respond to the the Array.uniq method. So this is the same-ish
    def make_unique(array)
      test_array = array
      count = 0

      array.reverse.each do |current_item|
        test_array.each do |test_item|
          if (current_item.fetch('title') == test_item.fetch('title') && current_item.fetch('revid') > test_item.fetch('revid') )
            # At this point, current is the same article as test, and current is newer. Delete test
            array.delete(test_item)
            count += 1
          end
        end
      end

      array
    end

    # This method will return the version of the MediaWiki server. This is done by parsing the
    # version number from the generator attribute of the the site_info method. Useful? Yes
    # - maybe yout bot is only compatible with MediaWiki 1.9.0 depending on what methods you
    # use. I like it, anwyay.
    def version
      site_info.fetch('generator').split[1]
    end

    # Make Request is a method that actually handles making the request to the API. Since the
    # API is somewhat standardized, this method is able to accept the action and a hash of
    # variables, and it handles all the fun things MediaWiki likes to be weird over, like
    # cookies and limits and actions. Its very solid, but I didn't want it public because
    # it also does some post processing, and that's not very OO.
    def make_request (action, post_this)
      post_this['format'] = 'xml'
      post_this['action'] = action

      if (@config['logged_in'])
        cookies = "#{@config['cookieprefix']}UserName=#{@config['lgusername']}; #{@config['cookieprefix']}UserID=#{@config['lguserid']}; #{@config['cookieprefix']}Token=#{@config['lgtoken']}; #{@config['cookieprefix']}_session=#{@config['_session']}"
      else
        cookies = ""
      end

      headers =  {
        'User-agent'=>'bot-RWikiBot/2.0-rc1',
        'Cookie' => cookies
      }

      r = Hash.new
      until post_this.nil?
        return_result, post_this = raw_call(headers, post_this)
        r.deep_merge(return_result.fetch(action))
      end

      r
    end

    # Raw Call handles actually, physically talking to the wiki. It is broken out to handle
    # query-continues where applicable. So, all the methods call make_request, and it calls
    # raw_call until raw_call returns a nil post_this.
    def raw_call(headers, post_this)
      request = Net::HTTP::Post.new(@config.fetch('uri').path, headers)
      request.set_form_data(post_this)
      net = Net::HTTP.new(@config.fetch('uri').host, @config.fetch('uri').port)
      net.use_ssl = (@config.fetch('uri').scheme == 'https')
      response = net.start { |http| http.request(request) }

      # Extra cookie handling. Because editing will be based on session IDs and it generates
      # a new one each time until you start responding. I doubt this will change.
      if (response.header['set-cookie'] != nil)
        @config['_session'] = response.header['set-cookie'].split("=")[1]
      end

      begin
        return_result = XmlSimple.xml_in(response.body, { 'ForceArray' => false })
      rescue Exception => e
        raise ResponseError, "Response was not valid XML", e, response
      end

      if return_result.has_key?('error')
        raise RWikiBotError, "#{return_result.fetch('error').fetch('code').capitalize}: #{return_result.fetch('error').fetch('info')}"
      end

      if !post_this.keys.any?{|k| k.include?('limit')} && return_result.has_key?('query-continue')
        return_result.fetch('query-continue').each do |key, value|
          return_result.fetch('query-continue').fetch(key).each do |x,y|
            post_this[x] = y
          end
        end
      else
        post_this = nil
      end

      [return_result, post_this]
    end
  end
end
