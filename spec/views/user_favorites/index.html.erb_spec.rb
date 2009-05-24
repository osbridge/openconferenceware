require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_favorites/index.html.erb" do
  include UserFavoritesHelper

  before(:each) do
    assigns[:user_favorites] = [
      stub_model(UserFavorite),
      stub_model(UserFavorite)
    ]
  end

  it "renders a list of user_favorites" do
    render
  end
end

