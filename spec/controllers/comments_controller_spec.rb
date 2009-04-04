require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  integrate_views
  fixtures :all

  before do
    @event = events(:open)
    @proposal = proposals(:quentin_widgets)
  end

  describe "index" do
    describe "shared forbidden index behaviors", :shared => true do
      describe "HTML" do
        before do
          get :index
        end

        it "should get redirect" do
          response.should be_redirect
        end
      end
    end

    describe "shared allowed index behaviors", :shared => true do
      describe "Atom" do
        it "should get error if not key was specified" do
          get :index, :format => "atom"

          response.should_not be_success
          response.should_not be_redirect
        end

        it "should get error if key is wrong" do
          get :index, :format => "atom", :secret => "MEOW"

          response.should_not be_success
          response.should_not be_redirect
        end

        it "should get data if key is right" do
          get :index, :format => "atom", :secret => CommentsController::SECRET

          response.should be_success
          comments = assigns(:comments)
          struct = Hash.from_xml(response.body)
          struct['feed']['entry'].size.should == comments.size
        end
      end
    end

    describe "anonymous user" do
      it_should_behave_like "shared forbidden index behaviors"
      it_should_behave_like "shared allowed index behaviors"
    end

    describe "mortal user" do
      before do
        login_as :quentin
      end

      it_should_behave_like "shared forbidden index behaviors"
      it_should_behave_like "shared allowed index behaviors"
    end

    describe "admin user" do
      before do
        login_as :aaron
      end

      after do
        logout
      end

      it_should_behave_like "shared allowed index behaviors"

      describe "HTML" do
        before do
          get :index
        end

        it "should display comments" do
          response.should be_success
          assigns(:comments).size.should > 0
        end
      end
    end
  end

  describe "create" do
    it "should reject comments from bots" do
      post :create, :quagmire => "omg"

      flash[:failure].should match(/robot/i)
      response.should be_redirect
    end

    it "should fail on empty comment" do
      email = "bubba@smith.com"
      message = "Yo"
      post :create

      flash.should have_key(:failure)
      assigns(:comment).should_not be_valid
    end

    it "should fail on incomplete comment" do
      post :create, :proposal_id => @proposal.id, :comment => {:email => "bubba@smith.com", :message => "", :proposal_id => @proposal.id,  }

      flash.should have_key(:failure)
      assigns(:comment).should_not be_valid
    end

    it "should fail on comment without a proposal" do
      email = "bubba@smith.com"
      message = "Yo"
      post :create, :comment => {:email => email, :message => message}

      flash.should have_key(:failure)
      assigns(:comment).should_not be_valid
    end

    it "should fail on comment with invalid proposal" do
      email = "bubba@smith.com"
      message = "Yo"
      post :create, :proposal_id => -1, :comment => {:email => email, :message => message, :proposal_id => -1}

      flash.should have_key(:failure)
      assigns(:comment).should_not be_valid
    end

    it "should create new comment" do
      email = "bubba@smith.com"
      message = "Yo"
      post :create, :proposal_id => @proposal.id, :comment => {:email => email, :message => message, :proposal_id => @proposal.id}

      flash.should_not have_key(:failure)
      assigns(:comment).should be_valid
      response.should redirect_to(proposal_url(@proposal, :commented => true))
    end

    it "should assign email if logged in" do
      login_as :quentin
      post :create, :comment => {:proposal_id => @proposal.id}

      comment = assigns(:comment)
      comment.should_not be_valid
      comment.email.should == users(:quentin).email
    end
  end

  describe "destroy" do
    it "should destroy" do
      login_as :aaron
      comment = comments(:clio_chupacabras_fbi)
      Comment.should_receive(:find).with(comment.id.to_s).and_return(comment)
      comment.should_receive(:destroy)
      delete :destroy, :id => comment.id, :format => :html

      flash.should have_key(:success)
      # response.should be_redirect # TODO why not?
    end
  end
end
