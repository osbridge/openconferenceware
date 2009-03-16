require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoomsController do
  it "should test RoomsController (which is very much like SessionTypesController)"
end
=begin
  def mock_room(stubs={})
    @mock_room ||= mock_model(Room, stubs)
  end

  describe "responding to GET index" do

    it "should expose all rooms as @rooms" do
      Room.should_receive(:find).with(:all).and_return([mock_room])
      get :index
      assigns[:rooms].should == [mock_room]
    end

    describe "with mime type of xml" do

      it "should render all rooms as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Room.should_receive(:find).with(:all).and_return(rooms = mock("Array of Rooms"))
        rooms.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET show" do

    it "should expose the requested room as @room" do
      Room.should_receive(:find).with("37").and_return(mock_room)
      get :show, :id => "37"
      assigns[:room].should equal(mock_room)
    end

    describe "with mime type of xml" do

      it "should render the requested room as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Room.should_receive(:find).with("37").and_return(mock_room)
        mock_room.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET new" do

    it "should expose a new room as @room" do
      Room.should_receive(:new).and_return(mock_room)
      get :new
      assigns[:room].should equal(mock_room)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested room as @room" do
      Room.should_receive(:find).with("37").and_return(mock_room)
      get :edit, :id => "37"
      assigns[:room].should equal(mock_room)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created room as @room" do
        Room.should_receive(:new).with({'these' => 'params'}).and_return(mock_room(:save => true))
        post :create, :room => {:these => 'params'}
        assigns(:room).should equal(mock_room)
      end

      it "should redirect to the created room" do
        Room.stub!(:new).and_return(mock_room(:save => true))
        post :create, :room => {}
        response.should redirect_to(room_url(mock_room))
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved room as @room" do
        Room.stub!(:new).with({'these' => 'params'}).and_return(mock_room(:save => false))
        post :create, :room => {:these => 'params'}
        assigns(:room).should equal(mock_room)
      end

      it "should re-render the 'new' template" do
        Room.stub!(:new).and_return(mock_room(:save => false))
        post :create, :room => {}
        response.should render_template('new')
      end

    end

  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested room" do
        Room.should_receive(:find).with("37").and_return(mock_room)
        mock_room.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :room => {:these => 'params'}
      end

      it "should expose the requested room as @room" do
        Room.stub!(:find).and_return(mock_room(:update_attributes => true))
        put :update, :id => "1"
        assigns(:room).should equal(mock_room)
      end

      it "should redirect to the room" do
        Room.stub!(:find).and_return(mock_room(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(room_url(mock_room))
      end

    end

    describe "with invalid params" do

      it "should update the requested room" do
        Room.should_receive(:find).with("37").and_return(mock_room)
        mock_room.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :room => {:these => 'params'}
      end

      it "should expose the room as @room" do
        Room.stub!(:find).and_return(mock_room(:update_attributes => false))
        put :update, :id => "1"
        assigns(:room).should equal(mock_room)
      end

      it "should re-render the 'edit' template" do
        Room.stub!(:find).and_return(mock_room(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested room" do
      Room.should_receive(:find).with("37").and_return(mock_room)
      mock_room.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the rooms list" do
      Room.stub!(:find).and_return(mock_room(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(rooms_url)
    end

  end

end
=end