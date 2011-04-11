require 'spec_helper'

describe SelectorVotesController do

  def mock_selector_vote(stubs={})
    @mock_selector_vote ||= mock_model(SelectorVote, stubs)
  end

  describe "POST create" do

    describe "when not logged in" do
      before do
        logout
      end

      it "should reject request" do
        SelectorVote.should_not_receive(:find)
        SelectorVote.should_not_receive(:new)

        post :create, :selector_vote => {:these => 'params'}

        flash[:failure].should =~ /selection committee/
        response.should redirect_to(login_path)
      end
    end

    describe "when logged in as non-selector" do
      before do
        @user = Factory :user, :selector => false
        login_as @user
      end

      it "should reject request" do
        SelectorVote.should_not_receive(:find)
        SelectorVote.should_not_receive(:new)

        post :create, :selector_vote => {:these => 'params'}

        flash[:failure].should =~ /selection committee/
        response.should redirect_to(login_path)
      end

    end

    describe "when logged in as member of selection comittee" do

      before do
        @user = Factory :user, :selector => true
        login_as @user

        @event = Factory :populated_event
        @proposal1 = proposal_for_event(@event)
        @proposal2 = proposal_for_event(@event)
      end

      describe "with valid params" do

        before do
          @selector_vote = mock_selector_vote(:save => true, :proposal => @proposal1)
          @selector_vote.should_receive(:user=).with(@user)
          SelectorVote.should_receive(:new).with({'these' => 'params'}).and_return(@selector_vote)
          post :create, :selector_vote => {:these => 'params'}
        end

        it "should create the vote" do
          assigns[:selector_vote].should equal(mock_selector_vote)
        end

        it "should have successful notification message" do
          flash[:success].should_not be_blank
        end

        it "should redirect to next proposal" do
          response.should redirect_to(proposal_path(@proposal2))
        end

      end

    end

  end

  describe "PUT update" do

    describe "when not logged in" do
      before do
        logout
      end

      it "should reject request" do
        SelectorVote.should_not_receive(:find)
        SelectorVote.should_not_receive(:new)

        put :update, :id => 42, :selector_vote => {:these => 'params'}

        flash[:failure].should =~ /selection committee/
        response.should redirect_to(login_path)
      end
    end

    describe "when logged in as non-selector" do
      before do
        @user = Factory :user, :selector => false
        login_as @user
      end

      it "should reject request" do
        SelectorVote.should_not_receive(:find)
        SelectorVote.should_not_receive(:new)

        put :update, :id => 42, :selector_vote => {:these => 'params'}

        flash[:failure].should =~ /selection committee/
        response.should redirect_to(login_path)
      end

    end

    describe "when logged in as member of selection comittee" do

      before do
        @user = Factory :user, :selector => true
        login_as @user

        @event = Factory :populated_event
        @proposal1 = proposal_for_event(@event)
        @proposal2 = proposal_for_event(@event)
      end

      describe "with valid params" do

        before do
          @selector_vote = mock_selector_vote(:save => true, :proposal => @proposal1)
          @selector_vote.should_receive(:user=).with(@user)
          @selector_vote.should_receive(:update_attributes).with({'these' => 'params'}).and_return(true)
          SelectorVote.should_receive(:find).with('42').and_return(@selector_vote)
          put :update, :id => '42', :selector_vote => {:these => 'params'}
        end

        it "should create the vote" do
          assigns[:selector_vote].should equal(mock_selector_vote)
        end

        it "should have successful notification message" do
          flash[:success].should_not be_blank
        end

        it "should redirect to next proposal" do
          response.should redirect_to(proposal_path(@proposal2))
        end

      end

    end

  end

end
