require 'spec_helper'

describe TracksController do
  include TracksHelper
  fixtures :all

  before do
    @event = stub_current_event!(event: events(:open))
    @controller.stub(assign_events: [])
    @track = create(:track, event: @event)
    @tracks_double = double("Array of Tracks")
    @tracks_scope_double = double("Tracks Scope", order: @tracks_double)
  end

  describe "responding to GET index" do

    it "should redirect to the tracks for the current event if none is given" do
      get :index
      response.should redirect_to(event_tracks_path(@event))
    end

    it "should expose all tracks from the current event as @tracks" do
      @event.should_receive(:tracks).and_return(@tracks_scope_double)
      get :index, event_id: @event.to_param
      assigns(:tracks).should == @tracks_double
    end

    describe "with mime type of xml" do
      it "should render all tracks from the current event as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @event.should_receive(:tracks).and_return(@tracks_scope_double)
        @tracks_double.should_receive(:to_xml).and_return("generated XML")
        get :index, event_id: @event.to_param
        response.body.should == "generated XML"
      end
    end

  end

  describe "responding to GET show" do

    it "should expose the requested track as @track" do
      Track.should_receive(:find).with("37").and_return(@track)
      get :show, event_id: @event.to_param, id: "37"
      assigns(:track).should equal(@track)
    end

    describe "with mime type of xml" do

      it "should render the requested track as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Track.should_receive(:find).with("37").and_return(@track)
        @track.should_receive(:to_xml).and_return("generated XML")
        get :show, event_id: @event.to_param, id: "37"
        response.body.should == "generated XML"
      end

    end

    describe "with an invalid track id" do
      it "should redirect to the tracks index" do
        Track.should_receive(:find).with("invalid").and_raise(ActiveRecord::RecordNotFound)
        get :show, event_id: @event.to_param, id: "invalid"
        response.should redirect_to(event_tracks_path(@event))
      end
    end

  end

  describe "as an admin" do
    before(:each) do
      login_as(:aaron)
    end

    describe "responding to GET new" do

      it "should expose a new track as @track" do
        Track.should_receive(:new).and_return(@track)
        get :new, event_id: @event.to_param
        assigns(:track).should equal(@track)
      end

    end

    describe "responding to GET edit" do

      it "should expose the requested track as @track" do
        Track.should_receive(:find).with("37").and_return(@track)
        get :edit, id: "37", event_id: @event.to_param
        assigns(:track).should equal(@track)
      end

    end

    describe "responding to POST create" do
      describe "with valid params" do
        before do
          @valid_params = extract_valid_params(@track)
          post :create, track: @valid_params, event_id: @event.to_param
        end

        it "should expose a newly created track as @track" do
          assigns(:track).should be_valid
          extract_valid_params(assigns(:track)).should eq(@valid_params)
        end

        it "should redirect to the tracks index" do
          response.should redirect_to(event_tracks_path(@event))
        end

      end

      describe "with invalid params" do
        before do
          post :create, track: {color: 'orange'}, event_id: @event.to_param
        end

        it "should expose a newly created but unsaved track as @track" do
          assigns(:track).should be_new_record
        end

        it "should re-render the 'new' template" do
          response.should render_template('new')
        end

      end

    end

    describe "responding to PUT update" do

      describe "with valid params" do
        before do
          @valid_params = extract_valid_params(@track)
          Track.should_receive(:find).with("37").and_return(@track)
          @track.should_receive(:update_attributes).with(@valid_params).and_return(true)
          put :update, id: "37", track: @valid_params, event_id: @event.to_param
        end

        it "should expose the requested track as @track" do
          assigns(:track).should equal(@track)
        end

        it "should redirect to the track" do
          response.should redirect_to(track_path(@track))
        end

      end

      describe "with invalid params" do
        before do
          @track.stub(:save).and_return(false)
          Track.should_receive(:find).with("37").and_return(@track)
          put :update, id: "37", track: {title: 'hello'}, event_id: @event.to_param
        end

        it "should expose the track as @track" do
          assigns(:track).should equal(@track)
        end

        it "should re-render the 'edit' template" do
          response.should render_template('edit')
        end

      end

    end

    describe "responding to DELETE destroy" do
      before do
        @track.stub(:destroy).and_return(true)
      end

      it "should destroy the requested track" do
        Track.should_receive(:find).with("37").and_return(@track)
        @track.should_receive(:destroy)
        delete :destroy, id: "37", event_id: @event.to_param
      end

      it "should redirect to the tracks list" do
        Track.stub(:find).and_return(@track)
        delete :destroy, id: "1", event_id: @event.to_param
        response.should redirect_to(event_tracks_path(@event))
      end

    end
  end

end
