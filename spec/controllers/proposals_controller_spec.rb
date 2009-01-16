require File.dirname(__FILE__) + '/../spec_helper'

describe ProposalsController, "when displaying events" do
  integrate_views
  fixtures :snippets, :events, :proposals, :users, :comments

  before(:all) do
    @current_event = Event.current
  end

  describe "index" do
    describe "when returning HTML" do
      before do
        get :index, :event_id => @current_event.id
      end

      it "should be successful" do
        response.should be_success
      end

      it "should assign an event" do
        assigns(:event).should == @current_event
      end

      it "should assign proposals" do
        assigns(:proposals).should_not be_blank
      end
    end

    describe "when returning CVS" do
      describe "shared CSV behaviors", :shared => true do
        before do
          get :index, :event_id => @current_event.id, :format => "csv"
          @rows = CSV::Reader.parse(response.body).inject([]){|result,row| result << row; result}
          @header = @rows.first
        end

        it "should return CSV" do
          @rows.should be_a_kind_of(Array)
        end

        it "should see public fields" do
          @header.should include("presenter")
        end
      end

      describe "anonymous user" do
        before do
          logout
        end

        it_should_behave_like "shared CSV behaviors"

        it "should not see private fields" do
          @header.should_not include("email")
        end
      end

      describe "mortal user" do
        before do
          login_as(:quentin)
        end

        it_should_behave_like "shared CSV behaviors"

        it "should not see private fields" do
          @header.should_not include("email")
        end
      end

      describe "admin user" do
        before do
          login_as(:aaron)
        end

        it_should_behave_like "shared CSV behaviors"

        it "should not see private fields" do
          @header.should include("email")
        end
      end
    end

    describe "when returning XML" do
      it "should return XML" do
        get :index, :event_id => @current_event.id, :format => "xml"

        proposals = assigns(:proposals)
        proposals.size.should >= 0

        struct = XmlSimple.xml_in_string(response.body)
        struct['proposal'].size.should == proposals.size
      end
    end

    describe "when returning JSON" do
      it "should return JSON" do
        get :index, :event_id => @current_event.id, :format => "json"

        proposals = assigns(:proposals)
        proposals.size.should >= 0

        struct = ActiveSupport::JSON.decode(response.body)
        struct.size.should == proposals.size
      end
    end
  end

  describe "show" do
    it "should display extant proposal" do
      proposal = proposals(:quentin_widgets)
      get :show, :id => proposal.id

      response.should be_success
      assigns(:proposal).should == proposal
    end

    it "should fail to display non-existent proposal" do
      get :show, :id => -1

      response.should redirect_to(proposals_url)
    end
  end

  describe "new" do
    describe "for open event" do
      it "should display form for open events" do
        get :new, :event_id => events(:open).id

        response.should be_success
        assigns(:proposal).should be_true
      end

      it "should not assign presenter if anonymous" do
        logout
        get :new, :event_id => events(:open).id

        response.should be_success
        proposal = assigns(:proposal)
        proposal.presenter.should be_blank
      end

      it "should assign presenter if logged in" do
        user = users(:quentin)
        login_as(user.login)
        get :new, :event_id => events(:open).id

        response.should be_success
        proposal = assigns(:proposal)
        proposal.presenter.should == user.fullname
      end
    end

    it "should not display form for closed events" do
      get :new, :event_id => events(:closed).id

      response.should be_redirect
    end
  end

  describe "edit" do
    describe "shared edit behaviors", :shared => true do
      before do
        @proposal = proposals(:quentin_widgets)
        get :edit, :id => @proposal.id
      end
    end

    describe "shared allowed edit behaviors", :shared => true do
      it_should_behave_like "shared edit behaviors"

      it "should not redirect with failure" do
        flash.should_not have_key(:failure)
        response.should be_success
      end
    end

    describe "shared forbidden edit behaviors", :shared => true do
      it_should_behave_like "shared edit behaviors"

      it "should redirect with failure" do
        flash.should have_key(:failure)
        response.should redirect_to(proposal_path(@proposal))
      end
    end

    describe "anonymous user" do
      before(){ logout }
      it_should_behave_like "shared edit behaviors"

      it "should redirect to login" do
        response.should redirect_to(new_session_url)
      end
    end

    describe "non-owner mortal user" do
      before(){ login_as :clio }
      it_should_behave_like "shared forbidden edit behaviors"
    end

    describe "owner mortal user" do
      before(){ login_as :quentin }
      it_should_behave_like "shared allowed edit behaviors"
    end

    describe "admin user" do
      before(){ login_as :aaron }
      it_should_behave_like "shared allowed edit behaviors"
    end

    describe "when closed" do
      it "should redirect if owner tries to edit proposal for closed event" do
        proposal = proposals(:clio_chupacabras)
        login_as :clio
        get :edit, :id => proposal.id

        response.should redirect_to(event_proposals_url(proposal.event))
      end

      it "should allow admin to edit" do
        proposal = proposals(:clio_chupacabras)
        login_as :aaron
        get :edit, :id => proposal.id

        response.should be_success
        assigns(:proposal).should == proposal
      end
    end
  end

  describe "create" do
    def assert_create(login=nil, inputs={}, &block)
      login ? login_as(login) : logout
      post :create, inputs
      @record = assigns(:proposal)
      block.call
    end

    before do
      @inputs = proposals(:quentin_widgets).attributes.clone
      @inputs['user_id'] = nil
      @record = nil
    end

    it "should redirect on login" do
      assert_create(nil, :event_id => @current_event.id, :commit => 'Login', :openid_url => 'http://foo.bar') do
        response.should be_redirect
        assigns(:proposal).should be_blank
      end
    end

    it "should create proposal for anonymous user" do
      assert_create(nil, :event_id => @current_event.id, :proposal => @inputs) do
        response.should be_redirect
        proposal = assigns(:proposal)
        proposal.should be_valid
      end
    end

    it "should create proposal for mortal user" do
      login_as :quentin
      assert_create(nil, :event_id => @current_event.id, :proposal => @inputs) do
        response.should be_redirect
        proposal = assigns(:proposal)
        proposal.should be_valid
      end
    end

    it "should fail to create proposal with invalid fields" do
      login_as :quentin
      inputs = @inputs.clone
      inputs['presenter'] = nil
      assert_create(nil, :event_id => @current_event.id, :proposal => inputs) do
        response.should be_success
        proposal = assigns(:proposal)
        proposal.should_not be_valid
      end
    end
  end

  describe "update" do
    def assert_update(login=nil, inputs={}, &block)
      login ? login_as(login) : logout
      put :update, :id => inputs['id'] || inputs[:id], :proposal => inputs
      block.call
    end

    before do
      @user = users(:quentin)
      @proposal = proposals(:quentin_widgets)
      @inputs = @proposal.attributes.clone
    end

    it "should redirect anonymous user to login" do
      assert_update(nil, @inputs) do
        response.should redirect_to(new_session_url)
      end
    end

    it "should reject non-owner mortal user" do
      assert_update(:clio, @inputs) do
        flash.should have_key(:failure)
        response.should redirect_to(proposal_url(@proposal))
      end
    end

    it "should allow owner mortal user" do
      assert_update(:quentin, @inputs) do
        flash.should have_key(:success)
        response.should redirect_to(proposal_url(@proposal))
      end
    end

    it "should allow admin user" do
      assert_update(:aaron, @inputs) do
        flash.should have_key(:success)
        response.should redirect_to(proposal_url(@proposal))
      end
    end

    it "should display edit form if fields are invalid" do
      inputs = @inputs.clone
      inputs['presenter'] = nil
      assert_update(:quentin, inputs) do
        response.should be_success
        response.should render_template('edit')
      end
    end
  end

  describe "delete" do
    before do
      @proposal = proposals(:quentin_widgets)
      @owner = @proposal.user
      Proposal.stub!(:lookup).and_return(@proposal)
    end

    def assert_delete(login=nil, &block)
      login ? login_as(login) : logout
      delete :destroy, :id => @proposal.id
      block.call
    end

    it "should ask anonymous to login" do
      @proposal.should_not_receive(:destroy)
      assert_delete do
        response.should redirect_to(new_session_url)
      end
    end

    it "should reject non-owner mortal user" do
      @proposal.should_not_receive(:destroy)
      assert_delete(:clio) do
        flash.should have_key(:failure)
        response.should redirect_to(proposal_url(@proposal))
      end
    end

    it "should allow owner mortal user" do
      @proposal.should_receive(:destroy)
      assert_delete(:quentin) do
        flash.should have_key(:success)
        response.should redirect_to(event_proposals_url(@proposal.event))
      end
    end

    it "should allow admin user" do
      @proposal.should_receive(:destroy)
      assert_delete(:quentin) do
        flash.should have_key(:success)
        response.should redirect_to(event_proposals_url(@proposal.event))
      end
    end
  end

  describe "br3ak" do
    it "should fail" do
      lambda { get :br3ak }.should raise_error
    end
  end
end
