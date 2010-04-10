# = SharedFragmentHelper
#
# This module provides functions to producing shared fragments, chunks of
# rendered HTML that are intended to be reused by other applications.
#
# The rendered files are placed into the
# "RAILS_ROOT/public/system/shared_fragments" directory.
#
# You can render the fragments from the command-line by running:
#   ./script/runner "SharedFragmentHelper.render_shared_fragments"
module SharedFragmentHelper
  # Provides the TestRequest and TestRequest objects for ::render_theme_header_to_string.
  require 'action_controller/test_process'

  # Should the shared fragments be rendered? Defaults to true.
  mattr_accessor :enabled
  @@enabled = true

  # Render all shared fragments to files.
  def self.render_shared_fragments
    Rails.logger.info("SharedFragmentHelper: rendering all shared fragments to files at #{self.shared_fragments_dir}")
    self.render_theme_headers_to_files
    return true
  end

  # Render the theme headers for all events in the database to files.
  def self.render_theme_headers_to_files
    self.render_theme_header_to_file # current
    for event in Event.lookup
      self.render_theme_header_to_file(event)
    end
    return true
  end

  # Render the theme's header to a file for the given +event+. If no event was
  # specified, will render the current event.
  def self.render_theme_header_to_file(event=nil)
    File.open(self.shared_fragment_path_for_header(event), 'w+') do |handle|
      handle.write(self.render_theme_header_to_string(event))
    end
    return true
  end

  # Return the directory path for storing the shared fragments.
  def self.shared_fragments_dir
    return File.join(Rails.public_path, 'system', 'shared_fragments')
  end

  # Return the file path for a header fragment, for the given +event+. If no
  # event was specified, will return a path for the current event.
  def self.shared_fragment_path_for_header(event=nil)
    return File.join(self.shared_fragments_dir, "header_#{event ? event.slug : 'current'}")
  end

  # Return a new ApplicationController that can be used for rendering fragments.
  def self.new_shared_fragment_app
    request = ActionController::TestRequest.new
    response = ActionController::TestResponse.new
    app = ApplicationController.new
    app.instance_eval do
      initialize_template_class(response)
      assign_shortcuts(request, response)
      initialize_current_url
    end
    return app
  end

  # Return a new ActionView that can be used for rendering fragments.
  def self.new_shared_fragment_renderer
    renderer = ActionView::Base.new(Rails::Configuration.new.view_path)
    renderer.extend ApplicationController.master_helper_module
    renderer.extend(ActionView::Helpers::UrlHelper)
    renderer.extend(ActionView::Helpers::TagHelper)
    renderer.controller = self.new_shared_fragment_app

    return renderer
  end

  # Return a string containing the theme's header for given event, or nil if
  # the theme doesn't have a header partial found.
  def self.render_theme_header_to_string(event=nil)
    unless self.enabled
      Rails.logger.info("SharedFragmentHelper: not rendering because disabled")
      return false
    end

    # Get an Event record:
    case event
    when Event
      # Accept given object
    when String, Symbol, Fixnum
      # Lookup by slug
      event = Event.lookup(event.to_s)
    else
      # Use current event
      event = Event.current
    end

    # Set up a Rails view renderer, and context.
    renderer = self.new_shared_fragment_renderer

    renderer.instance_variable_set(:@event, event)
    renderer.instance_variable_set(:@events, Event.lookup)

    # Render template:
    filename = theme_file('layouts/_header.html.erb')
    if File.exist?(filename)
      return renderer.render_file(filename)
    else
      return nil
    end
  end
end
