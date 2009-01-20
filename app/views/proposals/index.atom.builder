atom_feed do |feed|
  feed.title("#{SETTINGS.organization}: Presentation Proposals")
  feed.updated((@proposals.blank? ? Time.at(0) : @proposals.first.submitted_at))

  @proposals.each do |proposal|
    feed.entry(proposal, :url => proposal_url(proposal)) do |entry|
      entry.title(h proposal.title)

      xm = ::Builder::XmlMarkup.new
      xm.div {
        unless multiple_presenters?
          xm.dl {
            xm.dt { xm.b "Speaker:" }
            xm.dd proposal.presenter
          }
          xm.dl {
            xm.dt { xm.b "Biography:" }
            xm.dd << simple_format(escape_once proposal.biography)
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
          xm.dd << simple_format(escape_once proposal.description)
        }

        profiles = user_profiles? ? proposal.users : [proposal]

        if multiple_presenters?
          xm.div {
            xm.p { xm.b "Speaker(s):" }
            xm.ul {
              profiles.each do |profile|
                xm.li {
                  xm.p {
                    xm.b profile.presenter
                  }
                  xm << simple_format(escape_once profile.biography)
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
