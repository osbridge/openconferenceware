require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TracksController do
  include TracksHelper
  fixtures :all

  def mock_track(stubs={})
    stubs = stubs.merge({
      :title => 'Track',
      :event= => true,
      :event => events(:open)
    })
    return @mock_track ||= mock_model(Track, stubs)
  end
  
  before do
    @event = stub_current_event!(:event => events(:open))
  end
    
  describe "responding to GET index" do

    it "should expose all tracks from the current event as @tracks" do
      @event.should_receive(:tracks).and_return([mock_track])
      get :index
      assigns[:tracks].should == [mock_track]
    end

    describe "with mime type of xml" do
      it "should render all tracks from the current event as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @event.should_receive(:tracks).and_return(tracks = mock("Array of Tracks"))
        tracks.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end
    
  end

  describe "responding to GET show" do

    it "should expose the requested track as @track" do
      Track.should_receive(:find).with("37").and_return(mock_track)
      get :show, :id => "37"
      assigns[:track].should equal(mock_track)
    end
    
    describe "with mime type of xml" do

      it "should render the requested track as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Track.should_receive(:find).with("37").and_return(mock_track)
        mock_track.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
    describe "with an invalid track id" do
      it "should redirect to the tracks index" do
        Track.should_receive(:find).with("invalid").and_raise(ActiveRecord::RecordNotFound)
        get :show, :id => "invalid"
        response.should redirect_to(event_tracks_path(events(:open)))
      end
    end
    
  end

  describe "as an admin" do
    before(:each) do
      login_as(:aaron)
    end

    describe "responding to GET new" do
    
      it "should expose a new track as @track" do
        Track.should_receive(:new).and_return(mock_track)
        get :new, :event => events(:open).slug
        assigns[:track].should equal(mock_track)
      end

    end

    describe "responding to GET edit" do
    
      it "should expose the requested track as @track" do
        Track.should_receive(:find).with("37").and_return(mock_track)
        get :edit, :id => "37"
        assigns[:track].should equal(mock_track)
      end

    end
  
    describe "responding to POST create" do

      describe "with valid params" do
      
        it "should expose a newly created track as @track" do
          Track.should_receive(:new).with({'these' => 'params'}).and_return(mock_track(:save => true))
          post :create, :track => {:these => 'params'}
          assigns(:track).should equal(mock_track)
        end

        it "should redirect to the tracks index" do
          Track.stub!(:new).and_return(mock_track(:save => true))
          post :create, :track => {}
          response.should redirect_to(event_tracks_path(events(:open)))
        end
      
      end
    
      describe "with invalid params" do

        it "should expose a newly created but unsaved track as @track" do
          Track.stub!(:new).with({'these' => 'params'}).and_return(mock_track(:save => false))
          post :create, :track => {:these => 'params'}
          assigns(:track).should equal(mock_track)
        end

        it "should re-render the 'new' template" do
          Track.stub!(:new).and_return(mock_track(:save => false))
          post :create, :track => {}
          response.should render_template('new')
        end
      
      end
    
    end

    describe "responding to PUT update" do

      describe "with valid params" do

        it "should update the requested track" do
          Track.should_receive(:find).with("37").and_return(mock_track)
          mock_track.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :track => {:these => 'params'}
        end

        it "should expose the requested track as @track" do
          Track.stub!(:find).and_return(mock_track(:update_attributes => true))
          put :update, :id => "1"
          assigns(:track).should equal(mock_track)
        end

        it "should redirect to the track" do
          Track.stub!(:find).and_return(mock_track(:update_attributes => true))
          put :update, :id => "1"
          response.should redirect_to(track_path(mock_track))
        end

      end
    
      describe "with invalid params" do

        it "should update the requested track" do
          Track.should_receive(:find).with("37").and_return(mock_track)
          mock_track.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :track => {:these => 'params'}
        end

        it "should expose the track as @track" do
          Track.stub!(:find).and_return(mock_track(:update_attributes => false))
          put :update, :id => "1"
          assigns(:track).should equal(mock_track)
        end

        it "should re-render the 'edit' template" do
          Track.stub!(:find).and_return(mock_track(:update_attributes => false))
          put :update, :id => "1"
          response.should render_template('edit')
        end

      end

    end

    describe "responding to DELETE destroy" do

      it "should destroy the requested track" do
        Track.should_receive(:find).with("37").and_return(mock_track)
        mock_track.should_receive(:destroy)
        delete :destroy, :id => "37"
      end
  
      it "should redirect to the tracks list" do
        Track.stub!(:find).and_return(mock_track(:destroy => true))
        delete :destroy, :id => "1"
        response.should redirect_to(event_tracks_path(events(:open)))
      end

    end
  end

end
