module OpenConferenceWare
  # SnippetsHelper retrieves Snippet records and contents for views.
  module SnippetsHelper
    # Return the Snippet record matching the +slug+, else raise a
    # ActiveRecord::RecordNotFound.
    def snippet_record_for(slug)
      if record = Snippet.find_by_slug(slug.to_s)
        return record
      else
        raise ActiveRecord::RecordNotFound, "Can't find snippet: #{slug}"
      end
    end

    # Return the raw snippet content for a +slug+, else raises a
    # ActiveRecord::RecordNotFound.
    def raw_snippet_for(slug)
      snippet_record_for(slug).content
    end

    # Returns the snippet content adorned with an "Edit" link if the user is an
    # admin, the raw content if the user is a mortal, else raises a
    # ActiveRecord::RecordNotFound.
    def snippet_for(slug, use_simple_format=true)
      record = snippet_record_for(slug)
      string = record.content
      if admin?
        if matcher = string.match(%r{(.+)(</(?:div|p)>)\s*$}s)
          string = matcher[1] + link_to("Edit", edit_manage_snippet_path(record), class: :snippet_edit_link) + matcher[2]
        else
          string = string + link_to("Edit", edit_manage_snippet_path(record), class: :snippet_edit_link)
        end
      end
      return use_simple_format ? simple_format(string) : string
    end
  end
end
