require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserFavoritesController do
  fixtures :all

  def mock_user_favorite(stubs={})
    @mock_user_favorite ||= mock_model(UserFavorite, stubs)
  end

  # Return the data structure in the JSON response.
  def json_struct
    return ActiveSupport::JSON.decode(response.body)
  end

  describe "GET index" do
    it "assigns favorites for the given user as @user_favorites" do
      favorite = stub_model(UserFavorite)
      User.should_receive(:find).with('42').and_return(@user = stub_model(User))
      @user.stub!(:favorites => mock(Array, :populated => [favorite]))
      get :index, :user_id => '42'
      Undefer(assigns[:user_favorites]).should == [favorite]
    end
  end

  describe "PUT modify" do
    before(:each) do
      @owner = users(:quentin)
      @proposal = proposals(:aaron_aardvarks)
    end

    def add_favorite
      put :modify, :mode => "add", :user_id => @owner.id, :proposal_id => @proposal.id, :format => "json"
    end

    def remove_favorite
      put :modify, :mode => "remove", :user_id => @owner.id, :proposal_id => @proposal.id, :format => "json"
    end

    describe "add" do
      it "should allow owner" do
        login_as @owner

        proc { add_favorite }.should change(UserFavorite, :count).by(1)

        response.should be_success
        json_struct.should be_a_kind_of(Hash)
      end

      it "should not allow non-owner" do
        login_as :clio

        proc { add_favorite }.should_not change(UserFavorite, :count)

        response.should be_redirect
      end
    end

    describe "remove" do
      before(:each) do
        UserFavorite.add(@owner.id, @proposal.id)
      end

      it "should allow owner" do
        login_as @owner

        proc { remove_favorite }.should change(UserFavorite, :count).by(-1)

        response.should be_success
        json_struct.should be_a_kind_of(Hash)
      end

      it "should not allow non-owner" do
        login_as :clio

        proc { remove_favorite }.should_not change(UserFavorite, :count)

        response.should be_redirect
      end
    end

    describe "failure" do
      it "should not allow user to perform invalid oprations" do
        login_as @owner

        put :modify, :mode => "plaid", :user_id => @owner.id, :proposal_id => @proposal.id, :format => "json"

        response.should_not be_success
        response.should_not be_redirect
        json_struct.should include("error")
      end
    end

  end

end
