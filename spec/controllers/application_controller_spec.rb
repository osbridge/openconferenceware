require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  fixtures :snippets, :events, :proposals, :users, :comments

  def can_edit?(*args)
    return @controller.send(:can_edit?, *args)
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
      it "should allow user to edit own when accepting proposals" do
        login_as :quentin
        proposal = proposals(:quentin_widgets)
        can_edit?(proposal).should be_true
      end

      it "should not allow user to edit own when not accepting proposals" do
        login_as :clio
        can_edit?(proposals(:clio_chupacabras)).should be_false
      end

      it "should not allow user to edit other's when accepting proposals" do
        login_as :quentin
        can_edit?(proposals(:aaron_ardvarks)).should be_false
      end

      it "should allow admin to edit other's when not accepting proposals" do
        login_as :aaron
        can_edit?(proposals(:clio_chupacabras)).should be_true
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
