FactoryGirl.define do
  factory :authentication do
    provider "test_provider"
    sequence(:uid) { |n| "penguin#{n}" }
    name "Nils Olav"
    email
    info( {
      "first_name" => "Nils",
      "last_name" => "Olav",
      "description" => "Colonel-in-Chief Sir Nils Olav is a King Penguin living in Edinburgh Zoo, Scotland. He is the mascot and Colonel-in-Chief of the Norwegian Royal Guard.",
      "urls" => {
        "wikipedia" => "http://en.wikipedia.org/wiki/Nils_Olav"
      }
    } )
  end
end
