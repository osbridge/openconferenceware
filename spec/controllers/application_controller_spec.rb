require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  fixtures :all

  def can_edit?(*args)
    return @controller.send(:can_edit?, *args)
  end

  def accepting_proposals?(*args)
    return @controller.send(:accepting_proposals?, *args)
  end

  describe "can_edit?" do
    describe "users" do
      it "should allow user to edit own" do
        login_as :quentin
        can_edit?(users(:quentin)).should be_true
      end

      it "should not allow user to edit other's" do
        login_as :quentin
        can_edit?(users(:clio)).should be_false
      end

      it "should allow admin to edit other's" do
        login_as :aaron
        can_edit?(users(:clio)).should be_true
      end
    end

    describe "proposals" do
      describe "accepting_proposals?" do
        it "should be false without anything defined" do
          accepting_proposals?.should_not be_true
        end

        it "should be true when given open event" do
          accepting_proposals?(events(:open)).should be_true
        end

        it "should be false when given closed event" do
          accepting_proposals?(events(:closed)).should_not be_true
        end

        it "should be true when given open proposal" do
          accepting_proposals?(proposals(:quentin_widgets)).should be_true
        end

        it "should be false when given closed proposal" do
          accepting_proposals?(proposals(:clio_chupacabras)).should_not be_true
        end

        it "should be true when assigned open event instance" do
          @controller.instance_variable_set(:@event, events(:open))
          accepting_proposals?.should be_true
        end

        it "should be false when assigned closed instance" do
          @controller.instance_variable_set(:@event, events(:closed))
          accepting_proposals?.should_not be_true
        end
      end

      describe "when accepting" do
        it "should allow user to edit own when accepting proposals" do
          login_as :quentin
          proposal = proposals(:quentin_widgets)
          can_edit?(proposal).should be_true
        end
        
        it "should allow user to edit own before a status has been set" do
          login_as :quentin
          proposal = proposals(:quentin_widgets)
          proposal.status = 'proposed'
          can_edit?(proposal).should be_true
        end
        
        it "should not allow user to edit own once a status has been set" do
          login_as :quentin
          proposal = proposals(:quentin_widgets)
          proposal.status = 'accepted'
          pending # TODO decide when to stop editing
          can_edit?(proposal).should be_false
        end

        it "should not allow user to edit other's when accepting proposals" do
          login_as :quentin
          can_edit?(proposals(:aaron_aardvarks)).should be_false
        end
      end

      describe "when not accepting" do
        it "should not allow user to edit own when not accepting proposals" do
          login_as :clio
          pending "FIXME do we really want people to be able to edit forever?"
          can_edit?(proposals(:clio_chupacabras)).should be_false
        end

        it "should allow admin to edit other's when not accepting proposals" do
          login_as :aaron
          can_edit?(proposals(:clio_chupacabras)).should be_true
        end
      end
    end

    it "should not allow anonymous to edit anything" do
      can_edit?(Proposal.find(:first)).should be_false
    end

    it "should fail on nil" do
      login_as :quentin
      lambda { can_edit? }.should raise_error(ArgumentError)
    end

    it "should fail on unknown record type" do
      login_as :quentin
      lambda { can_edit?(42) }.should raise_error(TypeError)
    end
  end

  describe "assign_current_event_without_redirecting" do
    it "should detected :assigned_already" do
      @controller.instance_variable_set(:@event, events(:open))
      @controller.send(:assign_current_event_without_redirecting)

      @controller.instance_variable_get(:@event_assignment).should == :assigned_already
    end
  end

  describe "assert_current_event_or_redirect" do
    describe "when no events" do
      it "should direct admin users to event manager" do
        login_as :aaron
        @controller.instance_variable_set(:@event_assignment, :empty)
        @controller.should_receive(:manage_events_path)
        @controller.should_receive(:redirect_to)
        @controller.send(:assert_current_event_or_redirect)

        flash[:failure].should_not be_blank
      end

      it "should display a failure for non-admins" do
        logout
        @controller.instance_variable_set(:@event_assignment, :empty)
        @controller.should_receive(:render)
        @controller.send(:assert_current_event_or_redirect)

        flash[:failure].should_not be_blank
      end
    end
  end

  # These specs are evil. Surely there's a better way to describe the behavior of controller methods that rely on a request without testing them through an action?
  describe "normalize_event_path_or_redirect" do
    describe "with HTML" do
      it "should not redirect canonical requests" do
        @controller.should_receive(:request).any_number_of_times.and_return(mock(OpenStruct,
          :path => '/events/123/proposals',
          :format => 'html'))
        @controller.send(:normalize_event_path_or_redirect).should be_false
      end

      it "should redirect incomplete requests" do
        event = events(:open)
        @controller.stub!(:request).and_return(mock(OpenStruct,
          :path => '/proposals',
          :format => 'html',
          :protocol => 'http',
          :host_with_port => 'foo:80'))
        @controller.stub!(:relative_url_root).and_return('')

        @controller.instance_variable_set(:@event, event)
        @controller.should_receive(:redirect_to).with("/events/#{event.to_param}/application/")

        @controller.send(:normalize_event_path_or_redirect)
      end
    end

    describe "with JSON" do
      it "should not redirect canonical requests" do
        @controller.should_receive(:request).any_number_of_times.and_return(mock(OpenStruct,
          :path => '/events/123/proposals',
          :format => 'json'))
        @controller.send(:normalize_event_path_or_redirect).should be_false
      end

      it "should redirect incomplete requests" do
        @controller.should_receive(:request).any_number_of_times.and_return(mock(OpenStruct,
          :path => '/proposals',
          :format => 'json'))
        @controller.send(:normalize_event_path_or_redirect).should be_false
      end
    end
  end

  describe "assert_schedule_published" do
    before(:each) do
      @event = stub_current_event!
      @controller.instance_variable_set(:@event, @event)
    end

    describe "as admin" do
      before(:each) do
        login_as :aaron
      end

      it "should be able to view schedule when it's published" do
        @controller.stub!(:schedule_visible?).and_return(true)
        @controller.should_not_receive(:redirect_to)

        result = @controller.send(:assert_schedule_published)
        flash[:failure].should be_blank
      end

      it "should be able to view schedule before it's published" do
        @controller.stub!(:schedule_visible?).and_return(false)
        @controller.should_not_receive(:redirect_to)

        result = @controller.send(:assert_schedule_published)
        flash[:failure].should be_blank
        flash[:notice].should_not be_blank
      end
    end

    describe "as non-admin" do
      before(:each) do
        logout
      end

      it "should be able to view schedule when it's published" do
        @controller.stub!(:schedule_visible?).and_return(true)
        @controller.should_not_receive(:redirect_to)

        result = @controller.send(:assert_schedule_published)
        flash[:failure].should be_blank
      end

      it "should not be able to view schedule before it's published" do
        @controller.stub!(:schedule_visible?).and_return(false)
        @controller.should_receive(:redirect_to)

        @controller.send(:assert_schedule_published)
        flash[:failure].should_not be_blank
      end
    end

  end

  describe "current_user_cache_key" do
    it "should return id of currently logged-in user" do
      user = users(:quentin)
      login_as user

      @controller.send(:current_user_cache_key).should == user.id
    end

    it "should return -1 if not logged in" do
      logout

      @controller.send(:current_user_cache_key).should == -1
    end
  end

  describe "current_event_cache_key" do
    it "should return id of current event" do
      event = events(:open)
      @controller.instance_variable_set(:@event, event)

      @controller.send(:current_event_cache_key).should == event.id
    end

    it "should return -1 if no current event" do
      @controller.instance_variable_set(:@event, nil)

      @controller.send(:current_event_cache_key).should == -1
    end
  end

  describe "developer_mode?" do
    it "should not be in development mode when testing" do
      @controller.send(:development_mode?).should be_false
    end
  end

  describe "#notify" do
    it "should set a message if one isn't defined" do
      @controller.send(:notify, :failure, "OMG")

      flash[:failure].should == "OMG"
    end

    it "should append a message if one is defined" do
      @controller.send(:notify, :failure, "OMG.")
      @controller.send(:notify, :failure, "WTF.")
      @controller.send(:notify, :failure, "BBQ.")

      flash[:failure].should == "OMG. WTF. BBQ."
    end

    it "should fail if given an invalid level" do
      lambda { @controller.send(:notify, :omg, "kittens") }.should raise_error(ArgumentError)
    end
  end

  describe "current_user" do
    it "should login_from_session" do
      user = stub_model(User)
      session[:user] = user.id
      User.should_receive(:find_by_id).and_return(user)

      controller.send(:current_user).should == user
    end

    it "should login_from_basic_auth" do
      user = stub_model(User)
      controller.should_receive(:get_auth_data).and_return(["username", "password"])
      User.should_receive(:authenticate).and_return(user)

      controller.send(:current_user).should == user
    end

    it "should login_from_cookie" do
      token = "1234"
      user = stub_model(User, :remember_token => token, :remember_token_expires_at => 1.day.from_now)
      cookies[:auth_token] = token
      User.should_receive(:find_by_remember_token).and_return(user)
      user.should_receive(:remember_me)
      controller.response = response

      controller.send(:current_user).should == user
    end
  end

end
