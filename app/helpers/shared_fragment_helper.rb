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

  # Render all shared fragments to files.
  def self.render_shared_fragments
    Rails.logger.info("SharedFragmentHelper: rendering all shared fragments to files at #{self.shared_fragments_dir}")
    self.render_theme_headers_to_files
    return true
  end

  # Render the theme headers for all events in the database to files.
  def self.render_theme_headers_to_files
    self.render_theme_header_to_file # current
    for event in Event.all
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
    app = ApplicationController.new
    app.request = ActionController::TestRequest.new
    app.response = ActionController::TestResponse.new
    app.request_forgery_protection_token = false
    app.extend(ActionView::Helpers::UrlHelper)
    app.extend(ApplicationHelper)
    def app.controller; return self; end
    return app
  end

  # Return a string containing the theme's header for given event, or nil if
  # the theme doesn't have a header partial found.
  def self.render_theme_header_to_string(event=nil)
    # Get an Event record:
    case event
    when Event
      # Accept given object
    when String, Symbol, Fixnum
      # Lookup by slug
      event = Event.find_by_slug(event.to_s)
    else
      # Use current event or use a placeholder
      event = Event.current || Event.new
    end

    # Setup an Rails app and environment:
    app = self.new_shared_fragment_app
    app.instance_variable_set(:@event, event)

    # Render template:
    filename = theme_file('layouts/_header.html.erb')
    begin
      markup = File.read(filename)
    rescue Errno::ENOENT
      # No such file
      return nil
    end
    return ERB.new(markup, nil, '-').result(app.send(:binding))
  end
end
