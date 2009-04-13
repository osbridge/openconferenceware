Given /^I am interested in a proposal for a "([^\"]*)" event$/ do |kind|
  # TODO rework fixtures to use automatic identities
  #@event = Event.find(Fixtures.identify(kind))
  event_id = \
    case kind
    when "open" then 2009
    when "closed" then 1975
    else raise ArgumentError, "Unknown event_id: #{kind}"
    end
  @event = Event.find(event_id)
  @proposal = @event.proposals.first
end

Given /^the settings allow comments after the deadline: "([^\"]*)"$/ do |truth|
  unless truth.blank?
    SETTINGS.have_event_proposal_comments_after_deadline = boolean_for(truth)
  end
end

Given /^the event is accepting comments if after the deadline: "([^\"]*)"$/ do |truth|
  unless truth.blank?
    @event.accept_proposal_comments_after_deadline = boolean_for(truth)
    @event.save!
  end
end

When /^I visit the proposal$/ do
  get proposal_path(@proposal)
end

Then /^the comments form is displayed: "([^\"]*)"$/ do |truth|
  method = boolean_for(truth) ? :should : :should_not
  response.send(method, have_tag("#comment-form"))
end

