When /^I create a comment$/ do
  step 'I fill in "comment_email" with "my@address.com"'
  step 'I fill in "comment_message" with "Yay"'
  step 'I press "Create comment"'
end
