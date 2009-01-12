require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  integrate_views
  fixtures :events, :proposals, :users, :comments

  describe "index" do
    it "should list users" do
      get :index

      assigns(:users).should include(users(:aaron))
    end
  end

  describe "show" do
    it "should show user" do
      get :show, :id => users(:aaron).id

      assigns(:user).should == users(:aaron)
    end

    it "should redirect on invalid user" do
      get :show, :id => -1

      assigns(:user).should be_blank
      response.should redirect_to(users_path)
    end
  end

  describe "create" do
    # TODO implement
  end

  describe "update" do
    describe "anonymous user" do
      it "should not allow" do
        put :update, :user => {:id => users(:clio).id, :admin => true}

        response.should redirect_to(users_path)
        flash[:failure].should_not be_blank
      end
    end

    describe "mortal user" do
      before(:each) do
        @user = users(:clio)
        login_as @user
      end

      it "should allow edits of own record" do
        new_fullname = "Bubba Smith"
        put :update, :id => @user.id, :user => {
          :fullname => new_fullname
        }

        user = assigns(:user)
        user.fullname.should == new_fullname
      end

      it "should not allow editing of admin-only fields" do
        put :update, :id => @user.id, :user => {
          :admin => true
        }

        user = assigns(:user)
        user.admin.should be_false
      end

      it "should not allow editing of other records" do
        user = users(:aaron)
        put :update, :id => user.id, :user => {
          :fullname => "Jerky McJerkbag"
        }

        response.should redirect_to(users_path)
        flash[:failure].should_not be_blank
      end
    end

    describe "admin user" do
      before(:each) do
        login_as :aaron
      end

      it "should allow edits of any record's admin-only fields" do
        user = users(:quentin)
        put :update, :id => user.id, :user => {
          :admin => true
        }

        user = assigns(:user)
        user.admin.should be_true
      end
    end
  end

  describe "destroy" do
    it "should not allow mortal user to delete another user" do
      user = users(:clio)
      delete :destroy, :id => user.id

      User.exists?(user.id).should be_true
      flash[:failure].should_not be_blank
    end

    it "should allow admin" do
      login_as(:aaron)
      user = users(:clio)
      delete :destroy, :id => user.id

      User.exists?(user.id).should be_false
      flash[:success].should_not be_blank
    end
  end

end
