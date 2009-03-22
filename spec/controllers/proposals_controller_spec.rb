require File.dirname(__FILE__) + '/../spec_helper'

describe ProposalsController do
  integrate_views
  fixtures :all

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

    describe "when exporting", :shared => true do
      # Expects following to be set by implementor's #before block:
      # - @proposals
      # - @records
      # - @record

      it "should assign multiple items" do
        @proposals.size.should >= 1
      end

      it "should export same number of items as assigned" do
        @records.size.should == @proposals.size
      end

      it "should export presenter" do
        @record.keys.should include('presenter')
      end

      it "should not export email" do
        @record.keys.should_not include('email')
      end

      it "should not export private notes" do
        @record.keys.should_not include('note_to_organizers')
      end
    end

    describe "when returning XML" do
      before(:each) do
        get :index, :event_id => @current_event.id, :format => "xml"

        @proposals = assigns(:proposals)
        @struct = XmlSimple.xml_in_string(response.body)
        @records = @struct['record']
        @record = @records.first
      end

      it_should_behave_like "when exporting"
    end

    describe "when returning JSON" do
      before(:each) do
        get :index, :event_id => @current_event.id, :format => "json"

        @proposals = assigns(:proposals)
        @struct = ActiveSupport::JSON.decode(response.body)
        @records = @struct
        @record = @records.first
      end

      it_should_behave_like "when exporting"
    end

    describe "when sorting" do
      it "should sort proposals by title" do
        get :index, :sort => "title"
        proposals = assigns(:proposals)

        proposals.size.should > 0

        titles_returned = proposals.map(&:title)
        titles_expected = titles_returned.sort_by(&:downcase)
        titles_returned.should == titles_expected
      end

      it "should sort proposals by track" do
        get :index, :sort => "track"
        proposals = assigns(:proposals)

        proposals.size.should > 0

        tracks_returned = proposals.map{|proposal| proposal.track.title}
        tracks_expected = tracks_returned.sort_by(&:downcase)
        tracks_returned.should == tracks_expected
      end

      it "should sort proposals by title descending" do
        get :index, :sort => "title", :dir => "desc"
        proposals = assigns(:proposals)

        proposals.size.should > 0

        titles_returned = proposals.map(&:title)
        titles_expected = titles_returned.sort_by(&:downcase).reverse
        titles_returned.should == titles_expected
      end

      it "should not sort proposals by forbidden field" do
        proposal = Proposal.new
        proposal.should_not_receive(:destroy)

        event = Event.current
        event.should_receive(:lookup_proposals).and_return([proposal])
        @controller.should_receive(:get_current_event_and_assignment_status).and_return([event, :assigned_to_current])

        get :index, :sort => "destroy"
      end

    end

  end

  describe "sessions" do
    it "should display session_text" do
      event = stub_model(Event,
        :proposal_status_published? => true,
        :id => 1234,
        :session_text => "MySessionText",
        :proposals => mock_model(Array, :confirmed => [])
      )
      @controller.should_receive(:get_current_event_and_assignment_status).and_return([event, :assigned_to_current])

      get :confirmed, :event => 1234
      response.should have_tag(".event_text", event.session_text)
      response.should have_tag(".session_text", event.session_text)
    end

    it "should display a list of sessions" do
      proposal = stub_model(Proposal, :state => "confirmed", :users => [])
      confirmed = [proposal]
      proposals = mock_model(Array, :confirmed => confirmed)
      event = stub_model(Event, :proposal_status_published? => true, :id => 1234, :proposals => proposals)
      @controller.should_receive(:get_current_event_and_assignment_status).and_return([event, :assigned_to_current])
      get :confirmed, :event => 1234

      records = assigns(:proposals)
      records.should == confirmed
    end

    it "should redirect unless the proposal status is published" do
      event = stub_model(Event, :proposal_status_published? => false, :id => 1234)
      @controller.should_receive(:get_current_event_and_assignment_status).and_return([event, :assigned_to_current])
      get :confirmed, :event => 1234

      response.should redirect_to(proposals_url)
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
      describe "with user_profiles?" do
        before(:each) do
          SETTINGS.stub!(:have_user_profiles => true)
        end

        it "should redirect incomplete profiles to user edit form" do
          user = users(:incognito)
          login_as(user)
          get :new, :event_id => events(:open).id

          flash.should have_key(:notice)
          response.should redirect_to(edit_user_path(user, :require_complete_profile => true))
        end

        it "should allow users with complete profiles" do
          login_as(:quentin)
          get :new, :event_id => events(:open).id

          flash.should_not have_key(:failure)
          response.should be_success
        end
      end

      describe "without user_profiles?" do
        before(:each) do
          SETTINGS.stub!(:have_user_profiles => false)
        end

        describe "with anonymous_proposals" do
          before(:each) do
            SETTINGS.stub!(:have_anonymous_proposals => true)
          end

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
        end

        describe "without anonymous_proposals" do
          before(:each) do
            SETTINGS.stub!(:have_anonymous_proposals => false)
          end

          it "should redirect anonymous user to login" do
            get :new, :event_id => events(:open).id

            flash.should have_key(:notice)
            response.should redirect_to(login_path)
          end
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
        response.should redirect_to(login_url)
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
    # Try to create a proposal.
    #
    # Arguments:
    # * login: User to login as, can be nil for none, symbol or user object.
    # * inputs: Hash of properties to create a proposal from.
    def assert_create(login=nil, inputs={}, &block)
      login ? login_as(login) : logout
      # TODO extract :commit into separate argument
      post :create, inputs.reverse_merge(:commit => 'really')
      @record = assigns(:proposal)
      block.call
    end

    before do
      # TODO test other settings combinations
      SETTINGS.stub!(:have_proposal_excerpts => false)
      SETTINGS.stub!(:have_multiple_presenters => false)
      SETTINGS.stub!(:have_user_profiles => false)

      @inputs = proposals(:quentin_widgets).attributes.clone
      @inputs['user_id'] = nil
      @record = nil
    end

    describe "when anonymous proposals are enabled" do

      it "should redirect to OpenID login system if user tried to login" do
        SETTINGS.stub!(:have_anonymous_proposals).and_return(true)
        assert_create(nil, :event_id => @current_event.id, :commit => 'Login', :openid_url => 'http://foo.bar') do
          response.should be_redirect
          response.should redirect_to(browser_session_url(:openid_url => 'http://foo.bar'))
          assigns(:proposal).should be_blank
        end
      end

    end

    describe "with user_profiles?" do
      before(:each) do
        SETTINGS.stub!(:have_user_profiles => true)
      end

      it "should fail to create proposal without a complete user" do
        user = users(:quentin)
        user.should_receive(:complete_profile?).any_number_of_times.and_return(false)
        User.should_receive(:find_by_id).and_return(user)
        proposal = Proposal.new(@inputs)
        proposal.users << user
        Proposal.should_receive(:new).and_return(proposal)
        assert_create(user, :event_id => @current_event.id, :proposal => @inputs) do
          response.should be_success
          proposal = assigns(:proposal)
          proposal.should_not be_valid
        end
      end
    end

    describe "without user_profiles?" do
      before(:each) do
        SETTINGS.stub!(:have_user_profiles => false)
      end

      describe "with anonymous proposals" do
        before(:each) do
          SETTINGS.stub!(:have_anonymous_proposals => true)
        end

        it "should create proposal for anonymous user" do
          assert_create(nil, :event_id => @current_event.id, :proposal => @inputs) do
            proposal = assigns(:proposal)
            proposal.should be_valid
            proposal.id.should_not be_nil
          end
        end
      end

      describe "without anonymous proposals" do
        before(:each) do
          SETTINGS.stub!(:have_anonymous_proposals => false)
        end

        it "should not create proposal for anonymous user" do
          assert_create(nil, :event_id => @current_event.id, :proposal => @inputs) do
            response.should redirect_to(login_path)
          end
        end
      end

      it "should create proposal for mortal user" do
        assert_create(:quentin, :event_id => @current_event.id, :proposal => @inputs) do
          proposal = assigns(:proposal)
          proposal.should be_valid
          proposal.id.should_not be_nil
        end
      end

      it "should fail to create proposal without a presenter" do
        inputs = @inputs.clone
        inputs['presenter'] = nil
        assert_create(:quentin, :event_id => @current_event.id, :proposal => inputs) do
          response.should be_success
          proposal = assigns(:proposal)
          proposal.should_not be_valid
        end
      end
    end

    describe "theme-specific success page" do
      before(:each) do
        login_as(:quentin)
        @proposal = stub_model(Proposal, :id => 123)
        @proposal.should_receive(:save).and_return(true)
        @proposal.should_receive(:add_user).and_return(true)
        Proposal.should_receive(:new).and_return(@proposal)
      end

      it "should display theme-specific success page if it exists" do
        @controller.should_receive(:has_theme_specific_create_success_page?).and_return(true)
        @controller.should_receive(:render).and_return("My HTML here")

        post :create, :commit => "Create", :proposal => {}
      end

      it "should redirect back to proposal if it theme-specific success page doesn't exist" do
        @controller.should_receive(:has_theme_specific_create_success_page?).and_return(false)
        post :create, :commit => "Create", :proposal => {}

        response.should redirect_to(proposal_path(@proposal))
      end
    end

  end

  describe "update" do
    def assert_update(login=nil, inputs={}, &block)
      login ? login_as(login) : logout
      # TODO extract :commit?
      put :update, :id => inputs['id'] || inputs[:id], :proposal => inputs, :commit => 'really'
      block.call
    end

    before do
      @user = users(:quentin)
      @proposal = proposals(:quentin_widgets)
      @inputs = @proposal.attributes.clone
    end

    it "should redirect anonymous user to login" do
      assert_update(nil, @inputs) do
        response.should redirect_to(login_url)
      end
    end

    it "should reject non-owner mortal user" do
      assert_update(:clio, @inputs) do
        flash.should have_key(:failure)
        response.should redirect_to(proposal_url(@proposal))
      end
    end

    describe "when settings status" do
      it "should allow admin to change status" do
        @inputs[:transition] = 'accept'
        @controller.should_receive(:get_proposal_and_assignment_status).and_return([@proposal, :assigned_via_param])
        @proposal.should_receive(:accept!)
        assert_update(:aaron, @inputs) do
          # Everything is done through the should_receive
        end
      end

      it "should not allow non-admin to change status" do
        @inputs[:transition] = 'accept'
        @controller.should_receive(:get_proposal_and_assignment_status).and_return([@proposal, :assigned_via_param])
        @proposal.should_not_receive(:accept!)
        assert_update(:quentin, @inputs) do
        end
      end
    end

    describe "with user_profiles?" do
      before(:each) do
        SETTINGS.stub!(:have_user_profiles => true)
      end

      it "should specify update behavior"
    end

    describe "without user_profiles?" do
      before(:each) do
        SETTINGS.stub!(:have_user_profiles => false)
      end

      it "should display edit form if fields are invalid" do
        inputs = @inputs.clone
        inputs['presenter'] = nil
        assert_update(:quentin, inputs) do
          response.should be_success
          response.should render_template('edit')
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
    end
  end

  describe "delete" do
    before do
      @proposal = proposals(:quentin_widgets)
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
        response.should redirect_to(login_url)
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
