Factory.define :track do |f|
  f.sequence(:title) { |n| "Track #{n}" }
  f.description { |record| "#{record.title} description" }
  f.color "#000000"
  f.excerpt "A track"

  # :belongs_to association
  f.association :event
end
