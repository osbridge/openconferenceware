# == Schema Information
# Schema version: 20090510024259
#
# Table name: snippets
#
#  id          :integer         not null, primary key
#  slug        :string(255)     not null
#  description :string(255)     not null
#  content     :text            
#  value       :integer         
#  public      :boolean         default(TRUE)
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Snippet < ActiveRecord::Base
  # Provide cached Snippet.lookup(slug) method.
  include CacheLookupsMixin
  cache_lookups_for :slug, :order => :slug

  # Load the Snippets as defined in the "text/fixtures/snippets.yml" file and
  # load them into the current database, overwriting any existing records.
  def self.reload_from_fixtures!
    returning([]) do |records|
      data = YAML::load(ERB.new(File.read(File.join(RAILS_ROOT, "spec/fixtures/snippets.yml"))).result(binding))
      for attributes in data.values
        record = self.find_by_slug(attributes["slug"].to_s)
        if record
          record.update_attributes(attributes)
        else
          record = self.create!(attributes)
        end
        records << record
      end
    end
  end

  # Return a Snippet record for +slug+, but if it doesn't exist, create a new
  # one with the given +description+ and +content+.
  def self.make(slug, description, content)
    return self.find_or_create_by_slug(:slug => slug.to_s, :description => description, :content => content)
  end

  # Returns the content for a Snippet match +slug+, else raise an ActiveRecord::RecordNotFound.
  def self.content_for(slug)
    if record = self.lookup(slug.to_s)
      return record.content
    else
      raise ActiveRecord::RecordNotFound, "Couldn't find snippet: #{slug}"
    end
  end

  # Alternate syntax for ::content_for.
  def self.[](slug)
    return self.content_for(slug)
  end
end
