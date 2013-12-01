require 'nokogiri'
require 'rwikibot'

class RwikibotPageDrone
  attr_accessor :wiki
  attr_accessor :page
  attr_accessor :content
  attr_accessor :original_content

  def initialize(wiki, title)
    self.wiki = wiki
    self.page = self.wiki.page(title)
    self.content = self.get_content
    self.original_content = self.content.clone
  end

  def save(verbose=false)
    if self.modified?
      self.original_content = self.content.clone
      puts "Saved: #{self.page.title}" if verbose
      return self.page.save(self.content)
    else
      return false
    end
  end

  def append(*strings)
    strings = strings.flatten
    strings.each do |string|
      unless self.content.include?(string)
        self.content << "#{string}\n"
      end
    end
  end

  def replace(pattern, string)
    if self.content.match(pattern)
      return self.content.gsub!(pattern, string)
    else
      return self.append(string)
    end
  end

  def replace_span(identifier, string)
    doc = Nokogiri::HTML(self.content)
    element = doc.css("span##{identifier}")
    if element.size == 0
      self.append(%{<span id="#{identifier}">#{string}</span>})
    else
      element.to_html = string
      self.content = doc.to_s
    end
  end

  def modified?
    return content != original_content
  end

  def get_content
    if self.page.exists?
      if self.page.content.kind_of?(Hash) and value = self.page.content['content']
        return value
      else
        return self.page.content
      end
    else
      return ''
    end
  end
end
