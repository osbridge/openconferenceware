Then /^I should be able to destroy (\d+) comments$/ do |count|
  count = count.to_i
  if count > 0
    response.should have_tag(".proposal-comments a[href]", /Destroy/, count.to_i)
  else
    response.should_not have_tag(".proposal-comments a[href]", /Destroy/)
  end
end

When /^I destroy a comment$/ do
  @comment = @proposal.comments.first
  delete comment_path(@comment)
end
