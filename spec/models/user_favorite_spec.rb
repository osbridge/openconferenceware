require 'spec_helper'

describe UserFavorite do
  fixtures :all

  before(:each) do
    @user = users(:quentin)
    @proposal = proposals(:clio_chupacabras)
  end

  def add_favorite
    return UserFavorite.add(@user.id, @proposal.id)
  end

  def remove_favorite
    return UserFavorite.remove(@user.id, @proposal.id)
  end

  it "should add and create new record" do
    proc { add_favorite  }.should change(UserFavorite, :count).by(1)
  end

  it "should add and accept existing record" do
    add_favorite
    proc { add_favorite }.should_not change(UserFavorite, :count)
  end

  it "should remove and destroy existing record" do
    add_favorite
    proc { remove_favorite }.should change(UserFavorite, :count).by(-1)
  end

  it "should remove and do nothing if no existing record" do
    proc { remove_favorite }.should_not change(UserFavorite, :count)
  end

  it "should return ids of user's favorite proposals" do
    add_favorite
    UserFavorite.proposal_ids_for(@user).should == [@proposal.id]
  end
end
