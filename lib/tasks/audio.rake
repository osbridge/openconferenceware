namespace :open_conference_ware do
  namespace :audio do
    task :tag do
      raise NotImplementedError, "Port `scripts/add_i3_tags_to_mp3.rb` to a rake task."
    end

    desc "Add links from sessions to audio files"
    task :link => :environment do
      dir = ENV['DIR']
      pattern = ENV['PATTERN']
      url = ENV['URL']

      unless dir and pattern and url
        puts <<-HERE
  You must specify the following environmental variables:
  * DIR: The directory that the audio files are in.
  * PATTERN: The regular expression whose first capture group matches the session ID.
  * URL: The URL to prefix to audio files.

  Example: rake RAILS_ENV=production audio:link DIR=/var/www/bridgepdx_wordpress/audio/2010 PATTERN='^osb\\d+-(\\d+)' URL='http://opensourcebridge.org/audio/2010'
        HERE
        exit 1
      end

      require 'find'
      require 'pathname'

      Find.find(dir) do |node|
        path = Pathname.new(node)

        # Skip directories
        next unless path.file?

        basename = path.basename
        unless basename.to_s =~ /\.(mp3|ogg)$/
          puts "? Skipping non-audio file: #{path}"
          next
        end

        if matcher = basename.to_s.match(/#{pattern}/)
          session_id = matcher[1]
          session = OpenConferenceWare::Proposal.find(session_id)
          session.audio_url = "#{url}/#{URI.escape(path.relative_path_from(Pathname.new(dir)).to_s)}";
          puts "* Linking: #{path} to #{session.audio_url}"
          session.save!
        else
          puts "? Skipping file without session ID: #{path}"
          next
        end
      end
    end
  end
end
