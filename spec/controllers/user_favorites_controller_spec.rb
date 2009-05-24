require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserFavoritesController do
  fixtures :all

  def mock_user_favorite(stubs={})
    @mock_user_favorite ||= mock_model(UserFavorite, stubs)
  end

  describe "GET index" do
    it "assigns favorites for the given user as @user_favorites" do
      User.should_receive(:find).with('42').and_return(@user = stub_model(User))
      @user.should_receive(:favorites).and_return([mock_user_favorite])
      get :index, :user_id => '42'
      assigns[:user_favorites].should == [mock_user_favorite]
    end
  end

end
