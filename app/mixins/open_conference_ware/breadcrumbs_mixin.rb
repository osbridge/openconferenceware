module OpenConferenceWare

  # = BreadcrumbsMixin
  #
  # Adds breadcrumb trail to pages.
  #
  # == Usage
  #
  # In your application controller:
  #
  #   class Application < ActionController::Base
  #     include BreadcrumbsMixin
  #   end
  #
  # In each controller you want to add a resource-level breadcrumb:
  #
  #   class ThingsController < ActionController::Base
  #     add_breadcrumb "Things", "/things"
  #   end
  #
  # In each action you want to add a breadcrumb:
  #
  #   class ThingsController < ActionController::Base
  #     ...
  #
  #     def show
  #       ...
  #       @thing = Thing.find(params[:id])
  #       add_breadcrumb @thing.title, thing_path(@thing)
  #     end
  #   end
  module BreadcrumbsMixin

    def self.included(mixee)
      mixee.module_eval do
        # http://szeryf.wordpress.com/2008/06/13/easy-and-flexible-breadcrumbs-for-rails/

        # Add a breadcrumb. E.g.:
        #
        #   add_breadcrumb('Ignite Portland', 'http://igniteportland.com/')
        def add_breadcrumb(name, url='')
          @breadcrumbs ||= []
          url = eval(url) if url =~ /_path|_url|@/
          @breadcrumbs << [name, url]
        end

        # Add multiple breadcrumbs at once. Input is an array of arrays whose
        # elements are a name and URL. E.g.:
        #
        #   add_breadcrumbs([
        #     ['Ignite Portland', 'http://igniteportland.com/'],
        #     ['Proposals', '/proposals/'],
        #   ])
        def add_breadcrumbs(breadcrumbs)
          breadcrumbs.each do |breadcrumb|
            add_breadcrumb(*breadcrumb)
          end
        end

        # Add breadcrumb within a controller. Accepts same arguments as #add_breadcrumb.
        def self.add_breadcrumb(name, url='', options={})
          before_filter(options) do |controller|
            controller.send(:add_breadcrumb, name, url)
          end
        end

        # Add multiple breadcrumbs within a controller. Accepts same arguments as #add_breadcrumb.
        def self.add_breadcrumbs(breadcrumbs, options={})
          before_filter(options) do |controller|
            controller.send(:add_breadcrumbs, breadcrumbs)
          end
        end
      end
    end
  end
end
