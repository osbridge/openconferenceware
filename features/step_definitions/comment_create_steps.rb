When /^I create a comment$/ do
  When 'I fill in "comment_email" with "my@address.com"'
  When 'I fill in "comment_message" with "Yay"'
  When 'I press "Create comment"'
end
