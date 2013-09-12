Then /^I should get a "([^\"]*)" notification$/ do |kind|
  page.should have_selector(".alert-#{kind}")
end
