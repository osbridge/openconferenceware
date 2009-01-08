ip3 = Event.find(3) or raise "Can't find ip3"

# Transfer all existing proposals to ip3
for proposal in Proposal.find(:all)
  proposal.update_attribute(:event, ip3) unless proposal.event
end
