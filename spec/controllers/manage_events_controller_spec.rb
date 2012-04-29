require File.dirname(__FILE__) + '/../spec_helper'

describe Manage::EventsController do
  integrate_views
  fixtures :all

  before(:each) do
    @event = events(:open)
    login_as users(:aaron)
  end

  it "should retreive event show page" do
    get :index, :id => @event.slug

    response.should be_success
  end

  it "should retrieve new event form" do
    get :new, :id => @event.slug

    response.should be_success
  end

  it "should retrieve edit event form" do
    get :edit, :id => @event.slug

    response.should be_success
  end

  it "should update event" do
    stub_current_event!(:event => @event)
    attributes = { "title" => "omgwtfbbq" }
    @event.should_receive(:update_attributes).with(attributes).and_return(true)

    put :update, :id => @event.slug, :event => attributes

    response.should be_redirect
    flash[:notice].should_not be_blank
  end

  it "should create event"

  it "should destroy event"

  def setup_proposals(&block)
    @proposal_ids = ""
    @proposals = []
    %w[aaron_aardvarks quentin_widgets].each do |slug|
      proposal = proposals(slug)
      block.call proposal
      @proposal_ids << "#{proposal.id},"
      @proposals << proposal
    end
  end

  def assert_notified
    response.should be_redirect
    flash[:success].should =~ /aaron@example.com/
    flash[:success].should =~ /quentin@example.com/
  end

  it "should raise an error if trying to notify speakers other than accepted or rejected" do
    setup_proposals { |proposal| proposal.accept! }
    lambda { post :notify_speakers, { :id => @event.slug, :proposal_ids => @proposal_ids }  }.should raise_error(ArgumentError)
  end

  it "should skip proposals that don't exist" do
    setup_proposals { |proposal| proposal.accept! }
    post :notify_speakers, { :id => @event.slug, :proposal_ids => @proposal_ids+',999', :proposal_status => 'accepted' }

    assert_notified
  end

  it "should skip proposals that have already been notified" do
    setup_proposals do |proposal|
      proposal.accept!
      proposal.notified_at = Time.now
      proposal.save
    end
    post :notify_speakers, { :id => @event.slug, :proposal_ids => @proposal_ids, :proposal_status => 'accepted' }

    assert_notified
    flash[:success].should =~ /none/
    flash[:success].should =~ /already been notified/
  end

  it "should notify accepted speakers" do
    setup_proposals { |proposal| proposal.accept! }
    post :notify_speakers, { :id => @event.slug, :proposal_ids => @proposal_ids, :proposal_status => 'accepted' }

    assert_notified
    flash[:success].should_not =~ /already been notified/
  end

  it "should notify rejected speakers" do
    setup_proposals { |proposal| proposal.reject! }
    post :notify_speakers, { :id => @event.slug, :proposal_ids => @proposal_ids, :proposal_status => 'rejected' }

    assert_notified
    flash[:success].should_not =~ /already been notified/
  end
end
