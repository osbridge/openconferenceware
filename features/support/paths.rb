module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the homepage/
      root_path

    when /a proposal with comments/
      @proposal = Proposal.find(Fixtures.identify(:clio_chupacabras))
      proposal_path(@proposal)

    when /a proposal accepting comments/
      @proposal = Proposal.find(Fixtures.identify(:aaron_aardvarks))
      proposal_path(@proposal)

    # Add more page name => path mappings here

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
    end
  end
end

World(NavigationHelpers)
