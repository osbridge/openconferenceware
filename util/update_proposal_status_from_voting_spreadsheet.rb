# Accept and reject talks based on IDs from the scheduling spreadsheet
#
def accept_and_reject_from_spreadsheet
  # Paste IDs from spreadsheet, separated by spaces
  #             ↓↓↓
  reject =   %w(   ).map(&:to_i)
  accept =   %w(   ).map(&:to_i)
  waitlist = %w(   ).map(&:to_i)

  reject.each do |id|
    p = Proposal.find(id)
    p.reject! unless p.rejected?
  end

  accept.each do |id|
    p = Proposal.find(id)
    p.accept! unless p.accepted?
  end

  waitlist.each do |id|
    p = Proposal.find(id)
    p.waitlist! unless p.waitlisted?
  end
end

accept_and_reject_from_spreadsheet()
