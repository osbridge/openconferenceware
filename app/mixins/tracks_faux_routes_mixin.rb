# = FauxRoutesMixin
#
# The FauxRoutesMixin generates a bunch of route helpers for the
# TracksController and SessionTypesController nested resources.
#
# == Examples
#
# Long-hand way of expressing "/events/:event_id/tracks/:track_id":
#   event_track_path(@event, @track)
#
# Faux route helper for expressing the same thing and getting Event from @event:
#   track_path(@track)
#
module TracksFauxRoutesMixin
  # FIXME this implementation is 10x more complex than it should be, but I don't know how to make it simpler
  # FIXME this should be renamed / generalized since it now handles sesion types in addition to tracks.

  def self.included(mixee)
    mixee.extend(Methods)

    if mixee.ancestors.include?(ActionController::Base)
      mixee.class_eval do
        Methods.instance_methods.each do |name|
          #IK# puts "Helperized faux route: #{name}"
          helper_method(name)
        end
      end
    end
  end

  module Methods
    generate = proc{|*args|
      opts = args.extract_options!
      verb = opts[:verb]
      noun = opts[:noun]
      item = opts[:item]
      for kind in %w[path url]
        real = "#{verb ? verb+'_' : nil}event_#{noun}_#{kind}"
        faux = "#{verb ? verb+'_' : nil}#{noun}_#{kind}"
        #IK# puts "Creating faux route: #{faux} <= #{real}"
        if item
          define_method(faux, proc{|track, *args| send(real, track.event, track, *args)})
        else
          define_method(faux, proc{|*args| send(real, @event, *args)})
        end
      end
    }

    generate[:noun => "tracks"]
    generate[:noun => "track", :verb => "new"]
    generate[:noun => "track", :item => true]
    generate[:noun => "track", :verb => "edit", :item => true]
    
    generate[:noun => "session_types"]
    generate[:noun => "session_type", :verb => "new"]
    generate[:noun => "session_type", :item => true]
    generate[:noun => "session_type", :verb => "edit", :item => true]

    generate[:noun => "rooms"]
    generate[:noun => "room", :verb => "new"]
    generate[:noun => "room", :item => true]
    generate[:noun => "room", :verb => "edit", :item => true]
  end

  include Methods
  extend Methods

end
