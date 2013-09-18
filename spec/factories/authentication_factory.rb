Factory.define :authentication do |f|
  f.provider "test_provider"
  f.sequence(:uid) { |n| "penguin#{n}" }
  f.name "Nils Olav"
  f.email "nils@example.com"
  f.info( {
    "first_name" => "Nils",
    "last_name" => "Olav",
    "description" => "Colonel-in-Chief Sir Nils Olav is a King Penguin living in Edinburgh Zoo, Scotland. He is the mascot and Colonel-in-Chief of the Norwegian Royal Guard.",
    "urls" => {
      "wikipedia" => "http://en.wikipedia.org/wiki/Nils_Olav"
    }
  } )
end
