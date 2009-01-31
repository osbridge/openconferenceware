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

        it "should not allow user to edit other's when accepting proposals" do
          login_as :quentin
          can_edit?(proposals(:aaron_aardvarks)).should be_false
        end
      end

      describe "when not accepting" do
        it "should not allow user to edit own when not accepting proposals" do
          login_as :clio
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

  describe "assign_current_event_or_redirect" do
    describe "when no events" do
      it "should direct admin users to event manager" do
        login_as :aaron
        @controller.instance_variable_set(:@event_assignment, :empty)
        @controller.should_receive(:manage_events_path)
        @controller.should_receive(:redirect_to)
        @controller.send(:assign_current_event_or_redirect)

        flash[:failure].should_not be_blank
      end

      it "should display a failure for non-admins" do
        logout
        @controller.instance_variable_set(:@event_assignment, :empty)
        @controller.should_receive(:render)
        @controller.send(:assign_current_event_or_redirect)

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
        @controller.should_receive(:request).any_number_of_times.and_return(mock(OpenStruct,
          :path => '/proposals',
          :format => 'html',
          :protocol => 'http',
          :host_with_port => 'foo:80'))
        @controller.instance_variable_set(:@event, events(:open))
        @controller.should_receive(:redirect_to)
        @controller.send(:normalize_event_path_or_redirect).should_not be_false
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

end
