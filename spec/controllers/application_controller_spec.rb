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
          accepting_proposals?.should be_false
        end

        it "should be true when given open event" do
          accepting_proposals?(events(:open)).should be_true
        end

        it "should be false when given closed event" do
          accepting_proposals?(events(:closed)).should be_false
        end

        it "should be true when given open proposal" do
          accepting_proposals?(proposals(:quentin_widgets)).should be_true
        end

        it "should be false when given closed proposal" do
          accepting_proposals?(proposals(:clio_chupacabras)).should be_false
        end

        it "should be true when assigned open event instance" do
          @controller.instance_variable_set('@event', events(:open))
          accepting_proposals?.should be_true
        end

        it "should be false when assigned closed instance" do
          @controller.instance_variable_set('@event', events(:closed))
          accepting_proposals?.should be_false
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
end
