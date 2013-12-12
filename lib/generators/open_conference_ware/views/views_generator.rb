class OpenConferenceWare::ViewsGenerator < Rails::Generators::Base
  VIEWS_DIR = OpenConferenceWare::Engine.root.join('app','views')
  OCW_VIEW_DIRS = Pathname.glob(VIEWS_DIR.join("open_conference_ware","*/")).map{|d| d.basename.to_s } + ["layouts"]

  source_root VIEWS_DIR
  desc <<-DESC
Copies OCW's views into your application. By default, all views will be copied.

Optionally, you can pass specific view directories as arguments.

Available directories:
- #{OCW_VIEW_DIRS.join("\n- ")}

  DESC
  argument :which_views,
    type: :array, 
    default: ["all"],
    desc: "Which view directories to copy. One or more of: #{OCW_VIEW_DIRS.join(' ')}",
    banner: "VIEWS TO COPY"

  def copy_views
    directories_to_copy = if which_views.any?{|d| d == "all"}
                            OCW_VIEW_DIRS
                          else
                            which_views.select{|d| OCW_VIEW_DIRS.include?(d) }
                          end

    directories_to_copy.each do |dir|
      view_directory dir
    end
  end

  protected

  def view_directory(name)
    path = if name == "layouts"
              "layouts/open_conference_ware"
            else
              "open_conference_ware/#{name}"
            end

    directory path, "app/views/#{path}"
  end
end
