require 'spec_helper'

feature "managing snippets", type: :feature do
  background do
    mock_sign_in(:admin)
  end

  scenario "Adding a new snippet" do
    visit "/manage/snippets"
    click_link "New snippet"
    fill_in "Slug", with: "testing_snippet"
    fill_in "Description", with: "This is a snippet to test snippet editing"
    fill_in "Content", with: "lorem ipsum"
    click_button "Create"

    page.should have_content "Snippet was successfully created."
  end

  scenario "Editing a snippet" do
    snippet = create(:snippet)
    new_content = "!!snippet content!!"
    visit "/manage/snippets"
    click_link snippet.slug
    click_link "Edit"
    fill_in "Content", with: new_content
    click_button "Update"

    page.should have_content "Snippet was successfully updated."
    page.should have_content new_content
  end

  scenario "Deleting a snippet" do
    snippet = create(:snippet)
    visit manage_snippet_path(snippet)
    click_link "Destroy"
    page.should have_content "Snippet was deleted."
  end
end
