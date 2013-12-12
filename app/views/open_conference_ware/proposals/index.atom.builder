cache @cache_key do
atom_feed do |feed|
  feed.title("#{OpenConferenceWare.organization}: Presentation Proposals")
  feed.updated((@proposals.blank? ? Time.at(0) : @proposals.first.submitted_at))

  @proposals.each_with_index do |proposal, i|
    feed.entry(proposal, :url => proposal_url(proposal)) do |entry|
      entry.title proposal.title
      entry.updated proposal.submitted_at.utc.xmlschema

      xm = ::Builder::XmlMarkup.new
      xm.div {
        unless multiple_presenters?
          xm.dl {
            xm.dt { xm.b "Speaker:" }
            xm.dd proposal.presenter
          }
          xm.dl {
            xm.dt { xm.b "Biography:" }
            xm.dd << display_textile_for(proposal.biography)
          }
        end

        unless proposal.excerpt.blank?
          xm.dl {
            xm.dt { xm.b "Excerpt:" }
            xm.dd proposal.excerpt
          }
        end

        xm.dl {
          xm.dt { xm.b "Description:" }
          xm.dd << display_textile_for(proposal.description)
        }

        profiles = user_profiles? ? proposal.users : [proposal]

        if multiple_presenters?
          xm.div {
            xm.p { xm.b profiles.size == 1 ? "Speaker:" : "Speakers:" }
            xm.ul {
              profiles.each do |profile|
                xm.li {
                  xm.p {
                    xm.b profile.presenter
                  }
                  xm.div << display_textile_for(profile.biography)
                }
              end
            }
          }
        end
      }

      entry.content(xm.to_s, :type => 'html')

      entry.author do |author|
        author.name(proposal.presenter)
      end
    end
  end
end
end
