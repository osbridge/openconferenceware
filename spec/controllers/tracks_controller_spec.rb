require 'spec_helper'

describe TracksController do
  include TracksHelper
  fixtures :all
  
  before do
    @event = stub_current_event!(event: events(:open))
    @controller.stub(assign_events: [])
    @track = create(:track, event: @event)
  end
    
  describe "responding to GET index" do

    it "should redirect to the tracks for the current event if none is given" do
      get :index
      response.should redirect_to(event_tracks_path(@event))
    end

    it "should expose all tracks from the current event as @tracks" do
      @event.should_receive(:tracks).and_return([@track])
      get :index, event_id: @event.to_param
      assigns(:tracks).should == [@track]
    end

    describe "with mime type of xml" do
      it "should render all tracks from the current event as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @event.should_receive(:tracks).and_return(tracks = double("Array of Tracks"))
        tracks.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end
    
  end

  describe "responding to GET show" do

    it "should expose the requested track as @track" do
      Track.should_receive(:find).with("37").and_return(@track)
      get :show, id: "37"
      assigns(:track).should equal(@track)
    end
    
    describe "with mime type of xml" do

      it "should render the requested track as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Track.should_receive(:find).with("37").and_return(@track)
        @track.should_receive(:to_xml).and_return("generated XML")
        get :show, id: "37"
        response.body.should == "generated XML"
      end

    end
    
    describe "with an invalid track id" do
      it "should redirect to the tracks index" do
        Track.should_receive(:find).with("invalid").and_raise(ActiveRecord::RecordNotFound)
        get :show, id: "invalid"
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
        get :new, event: @event.to_param
        assigns(:track).should equal(@track)
      end

    end

    describe "responding to GET edit" do
    
      it "should expose the requested track as @track" do
        Track.should_receive(:find).with("37").and_return(@track)
        get :edit, id: "37"
        assigns(:track).should equal(@track)
      end

    end
  
    describe "responding to POST create" do
      before do
        @new_track = Track.new
      end

      describe "with valid params" do
        before do
          @valid_params = @track.attributes.slice(*Track.accessible_attributes(:admin)).clone
        end
      
        it "should expose a newly created track as @track" do
          post :create, track: @valid_params
          assigns(:track).attributes.slice(*Track.accessible_attributes(:admin)).should eq(@valid_params)
        end

        it "should redirect to the tracks index" do
          Track.stub(:new).and_return(@new_track)
          @new_track.stub(:save).and_return(true)

          post :create, track: {}
          response.should redirect_to(event_tracks_path(@event))
        end
      
      end
    
      describe "with invalid params" do
        before do
          @new_track.stub(:save).and_return(false)
        end

        it "should expose a newly created but unsaved track as @track" do
          Track.stub(:new).and_return(@new_track)
          post :create, track: {title: 'hello'}
          assigns(:track).should equal(@new_track)
          assigns(:track).should be_new_record
        end

        it "should re-render the 'new' template" do
          Track.stub(:new).and_return(@new_track)
          post :create, track: {}
          response.should render_template('new')
        end
      
      end
    
    end

    describe "responding to PUT update" do

      describe "with valid params" do
        before do
          @valid_params = @track.attributes.slice(*Track.accessible_attributes(:admin)).clone
          @track.stub(:save).and_return(true)
        end

        it "should update the requested track" do
          Track.should_receive(:find).with("37").and_return(@track)
          @track.should_receive(:assign_attributes).with(@valid_params, as: :admin)
          put :update, id: "37", track: @valid_params
        end

        it "should expose the requested track as @track" do
          Track.stub(:find).and_return(@track)
          put :update, id: "1"
          assigns(:track).should equal(@track)
        end

        it "should redirect to the track" do
          Track.stub(:find).and_return(@track)
          put :update, id: "1"
          response.should redirect_to(track_path(@track))
        end

      end
    
      describe "with invalid params" do
        before do
          @track.stub(:save).and_return(false)
        end

        it "should update the requested track" do
          Track.should_receive(:find).with("37").and_return(@track)
          put :update, id: "37", track: {title: 'hello'}
        end

        it "should expose the track as @track" do
          Track.stub(:find).and_return(@track)
          put :update, id: "1"
          assigns(:track).should equal(@track)
        end

        it "should re-render the 'edit' template" do
          Track.stub(:find).and_return(@track)
          put :update, id: "1"
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
        delete :destroy, id: "37"
      end
  
      it "should redirect to the tracks list" do
        Track.stub(:find).and_return(@track)
        delete :destroy, id: "1"
        response.should redirect_to(event_tracks_path(@event))
      end

    end
  end

end
