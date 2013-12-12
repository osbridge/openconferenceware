require 'spec_helper'

describe OpenConferenceWare::SelectorVotesController do
  routes { OpenConferenceWare::Engine.routes }

  def mock_selector_vote(stubs={})
    @mock_selector_vote ||= mock_model(SelectorVote, stubs)
  end

  describe "GET index" do

    describe "when not logged in" do
      before do
        logout

        SelectorVote.should_not_receive(:find)

        get :index
      end

      it "should reject request and redirect to login page" do
        response.should redirect_to(sign_in_path)
      end
    end

    describe "when logged in as non-selector" do
      before do
        @user = create( :user, selector: false )
        login_as @user

        SelectorVote.should_not_receive(:find)

        get :index
      end

      it "should reject request and redirect to login page" do
        response.should redirect_to(sign_in_path)
      end

    end

    describe "when logged in as member of selection comittee" do
      before do
        Event.destroy_all # Previous tests may have left an event behind

        @user = create :selector
        login_as @user
      end

      describe "without an event" do
        before do
          get :index
        end

        it "should redirect to root path" do
          response.should redirect_to(root_path)
        end

        it "should notify user of error" do
          flash[:failure].should =~ /Can't display selector votes/
        end
      end

      describe "with an event" do
        before do
          @user1 = create :selector
          @user2 = create :selector

          @event = create :populated_event

          @proposal1 = proposal_for_event(@event)
          @proposal2 = proposal_for_event(@event)

          @selector_vote1 = @proposal1.selector_votes.create user: @user1, rating: 1, comment: "Meh."
          @selector_vote2 = @proposal1.selector_votes.create user: @user2, rating: 5, comment: "Yay!"
        end

        shared_examples_for "HTML and CSV" do
          it "should have event" do
            assigns(:event).should == @event
          end

          it "should have proposals" do
            assigns(:proposals).size.should == 2
          end

          it "should include proposals without selector votes" do
            assigns(:proposals).should include(@proposal2)
          end

          it "should include proposals with selector votes" do
            assigns(:proposals).should include(@proposal1)
          end

          it "should include selector votes for a proposal" do
            proposal = assigns(:proposals).find { |o| o == @proposal1 }
            selector_vote1 = proposal.selector_votes.should include(@selector_vote1)
            selector_vote2 = proposal.selector_votes.should include(@selector_vote2)
          end
        end

        describe "requesting HTML" do
          before do
            get :index, event_id: @event.slug
          end

          it_should_behave_like "HTML and CSV"

          it "should render successfully" do
            response.should be_success
          end

          # NOTE: The assiciated view spec is very complete: spec/views/selector_votes/index.html.erb_spec.rb
        end

        describe "requesting CSV" do
          before do
            get :index, event_id: @event.slug, format: 'csv'
            @struct = CSV.parse(response.body)
            @row_for_proposal1 = @struct.find{|row| row.first == @proposal1.id.to_s}
            @row_for_proposal2 = @struct.find{|row| row.first == @proposal2.id.to_s}
            @column_with_selector_points = @struct.first.rindex{|column| column == "Selector points"}
          end

          it_should_behave_like "HTML and CSV"

          it "should render successfully" do
            response.should be_success
          end

          it "should contain a header" do
            @struct.first.should include("Id")
          end

          it "should contain a column with selector points" do
            @column_with_selector_points.should > 0
          end

          it "should contain proposal with selector votes" do
            @row_for_proposal1.should_not be_blank
          end

          it "should have correct selector points for proposal with selector votes" do
            @row_for_proposal1[@column_with_selector_points].to_i.should == @proposal1.selector_vote_points
          end

          it "should contain proposal without selector votes" do
            @row_for_proposal2.should_not be_blank
          end

          it "should have zero selector points for proposal without selector votes" do
            @row_for_proposal2[@column_with_selector_points].to_i.should == 0
          end
        end
      end
    end

  end

  describe "POST create" do

    describe "when not logged in" do
      before do
        logout
      end

      it "should reject request and redirect to login page" do
        SelectorVote.should_not_receive(:find_or_initialize_by)

        post :create, selector_vote: {these: 'params'}, proposal_id: "1"

        flash[:alert].should =~ /selection committee/
        response.should redirect_to(sign_in_path)
      end
    end

    describe "when logged in as non-selector" do
      before do
        @user = create :user, selector: false
        login_as @user
      end

      it "should reject request and redirect to login page" do
        SelectorVote.should_not_receive(:find_or_initialize_by)

        post :create, selector_vote: {these: 'params'}, proposal_id: "1"

        flash[:alert].should =~ /selection committee/
        response.should redirect_to(sign_in_path)
      end

    end

    describe "when logged in as member of selection comittee" do

      before do
        @user = create :user, selector: true
        login_as @user

        @event = create :populated_event
        @proposal1 = proposal_for_event(@event)
        @proposal2 = proposal_for_event(@event)
      end

      describe "with valid params" do

        before do
          @parameters = {proposal_id: @proposal1.id, selector_vote: {"comment" => 'Yay!', "rating" => "5"}}
          @selector_vote = mock_selector_vote(save: true, proposal: @proposal1)
          @selector_vote.should_receive(:assign_attributes).with(@parameters[:selector_vote])
          SelectorVote.should_receive(:find_or_initialize_by).with(user_id: @user.id, proposal_id: @proposal1.id).and_return(@selector_vote)
          post :create, @parameters
        end

        it "should create the vote" do
          assigns(:selector_vote).should equal(mock_selector_vote)
        end

        it "should redirect to next proposal" do
          response.should redirect_to(proposal_path(@proposal2))
        end

        it "should not display an error" do
          flash[:failure].should be_nil
        end

      end

      describe "with existing vote" do

        before do
          SelectorVote.destroy_all
          @selector_vote = SelectorVote.create!(user: @user, proposal: @proposal1, rating: 1, comment: 'Yay')
          SelectorVote.count.should == 1

          post :create, proposal_id: @proposal1.id, selector_vote: {comment: 'Nay', rating: 0}
        end

        it "should not create a new vote" do
          SelectorVote.count.should == 1
        end

        it "should update the vote" do
          @selector_vote.reload
          @selector_vote.rating.should == 0
          @selector_vote.comment.should == 'Nay'
        end

        it "should redirect to next proposal" do
          response.should redirect_to(proposal_path(@proposal2))
        end

        it "should not display an error" do
          flash[:failure].should be_nil
        end

      end

    end

  end

end
