module OpenConferenceWare

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
  module FauxRoutesMixin
    # FIXME this implementation is 10x more complex than it should be, but I don't know how to make it simpler

    TRACE = false

    def self.included(mixee)
      mixee.extend(Methods)

      if mixee.ancestors.include?(ActionController::Base)
        mixee.class_eval do
          Methods.instance_methods.each do |name|
            Rails.logger.debug("Faux route, helperized: #{name}") if TRACE
            helper_method(name)
          end
        end
      end
    end

    module Methods
      # Create a single route for the +options+.
      faux_route_for = lambda do |opts|
        verb = opts[:verb] # The action prefix for the route, e.g., the "new" in "new_track".
        noun = opts[:noun] # The singular resource to create a route for, e.g., "track".
        item = opts[:item] # Does this verb operate on an item and need an id, e.g., "new_track" does not, but "edit_track" does.
        for kind in %w[path url]
          real = "#{verb ? verb+'_' : nil}event_#{noun}_#{kind}"
          faux = "#{verb ? verb+'_' : nil}#{noun}_#{kind}"
          msg = nil
          if item
            msg = "Faux route, created for item: #{faux} <= #{real}"
            define_method(faux, proc{|item, *args| send(real, item.event, item, *args)})
          else
            msg = "Faux route, created for inference: #{faux} <= #{real}"
            define_method(faux, proc{|*args|
              event = @event
              if ! event && self.respond_to?(:get_current_event_and_assignment_status)
                event = self.get_current_event_and_assignment_status.first
              end
              raise ArgumentError, "No event found for faux route" unless event
              send(real, event, *args)
            })
          end
          Rails.logger.debug(msg) if TRACE
        end
      end

      # Create all common routes for this +resource+.
      faux_routes_for = lambda do |resource|
        resource = resource.to_s.singularize
        faux_route_for[noun: resource]
        faux_route_for[noun: resource.pluralize]
        faux_route_for[noun: resource, verb: "new"]
        faux_route_for[noun: resource, item: true]
        faux_route_for[noun: resource, verb: "edit", item: true]
      end

      # Create faux routes for the following +resources+:
      faux_routes_for["tracks"]
      faux_routes_for["session_types"]
      faux_routes_for["rooms"]
      faux_routes_for["schedule_items"]
    end

    include Methods
    extend Methods

  end
end
