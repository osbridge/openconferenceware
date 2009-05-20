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
end
