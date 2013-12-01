require 'spec_helper'

describe "mocking OmniAuth for testing" do
  before do
    mock_sign_in(:admin)
  end

  it "signs me in" do
    page.should have_content("Sign Out")
  end
end
