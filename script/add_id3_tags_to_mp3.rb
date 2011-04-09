#!/usr/bin/env ruby

# TODO make this into a rake task
# TODO extract configuration into user-settable variables

# SUMMARY: Adds ID3 tags to MP3 files based on sessions.
# SETUP: gem install ruby-mp3info

require 'find'

require 'rubygems'
require 'mp3info'

ENV['RAILS_ENV'] = 'production' unless ENV['RAILS_ENV']
load File.dirname($0) + '/../config/environment.rb'

Find.find(*ARGV) do |path|
  basename = File.basename(path)
  next unless basename =~ /\.(mp3|ogg)$/
  next unless FileTest.file?(path)
  puts path
  if matcher = basename.match(/^osb(\d+)-(\d+)/) # TODO extract configuration value
    begin
      year = matcher[1].to_i # TODO extract year from the session's event, rather than the filename
      session_id = matcher[2].to_i
      session = Proposal.find(session_id)
      Mp3Info.open(path) do |h|
        h.tag.year = year
        h.tag.album = "Open Source Bridge #{year}" # TODO extract configuration value
        # Don't set track number because it's limited to values 0-254
        ### h.tag.tracknum = session_id
        h.tag.tracknum = 0
        h.tag.artist = session.users.map(&:fullname).join(' / ')
        h.tag.title = session.title
        h.tag.genre = 101 # Speech # TODO extract configuration value
        h.tag.comments = 'http://opensourcebridge.org/' # TODO extract configuration value
        h.tag2.TIT1 = session.track.title if session.track
        h.tag2.TIT3 = session.excerpt
        h.tag2.TDES = session.excerpt
        h.tag2.COMM = session.description
        # h.tag2.TDAT = 

        h.flush
      end
    rescue Exception => e
      if e.kind_of?(Mp3InfoError) and e.to_s == "empty file"
        puts "ERROR! Empty file: #{path}"
      else
        puts "ERROR! Something bad happened: #{e}"
        require 'rubygems'; require 'ruby-debug'; Debugger.start; debugger; 1 # FIXME
      end
    end
  else
    puts "ERROR! Can't parse path: #{path}"
    require 'rubygems'; require 'ruby-debug'; Debugger.start; debugger; 1 # FIXME
  end
end
