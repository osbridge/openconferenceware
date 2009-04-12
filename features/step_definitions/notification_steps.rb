Then /^I should get a "([^\"]*)" notification$/ do |kind|
  flash[kind.to_sym].should_not be_blank
end
