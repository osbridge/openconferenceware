require 'spec_helper'

describe OpenConferenceWare::RoomsController do
  include OpenConferenceWare::RoomsHelper
  fixtures :all
  routes { OpenConferenceWare::Engine.routes }

  before do
    @event = stub_current_event!(event: events(:open))
    @room = create(:room, event: @event)
  end

  describe "responding to GET index" do

    it "should redirect to the rooms for the current event if none is given" do
      get :index
      response.should redirect_to(event_rooms_path(@event))
    end

    it "should expose all rooms from the current event as @rooms" do
      @event.should_receive(:rooms).and_return([@room])
      get :index, event_id: @event.to_param
      assigns(:rooms).should == [@room]
    end

    describe "with mime type of xml" do
      it "should render all rooms from the current event as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @event.should_receive(:rooms).and_return(rooms = double("Array of Rooms"))
        rooms.should_receive(:to_xml).and_return("generated XML")
        get :index, event_id: @event.to_param
        response.body.should == "generated XML"
      end
    end

  end

  describe "responding to GET show" do

    it "should expose the requested room as @room" do
      Room.should_receive(:find).with("37").and_return(@room)
      get :show, id: "37", event_id: @event.to_param
      assigns(:room).should equal(@room)
    end

    describe "with mime type of xml" do

      it "should render the requested room as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Room.should_receive(:find).with("37").and_return(@room)
        @room.should_receive(:to_xml).and_return("generated XML")
        get :show, id: "37", event_id: @event.to_param
        response.body.should == "generated XML"
      end

    end

    describe "with an invalid room id" do
      it "should redirect to the rooms index" do
        Room.should_receive(:find).with("invalid").and_raise(ActiveRecord::RecordNotFound)
        get :show, id: "invalid", event_id: @event.to_param
        response.should redirect_to(event_rooms_path(events(:open)))
      end
    end

  end

  describe "as an admin" do
    before(:each) do
      login_as(:aaron)
    end

    describe "responding to GET new" do
      before do
        @new_room = Room.new
      end

      it "should expose a new room as @room" do
        Room.should_receive(:new).and_return(@new_room)
        get :new, event_id: @event.to_param
        assigns(:room).should equal(@new_room)
      end

    end

    describe "responding to GET edit" do

      it "should expose the requested room as @room" do
        Room.should_receive(:find).with("37").and_return(@room)
        get :edit, id: "37", event_id: @event.to_param
        assigns(:room).should equal(@room)
      end

    end

    describe "responding to POST create" do
      describe "with valid params" do
        before do
          @valid_params = extract_valid_params(@room)
          post :create, room: @valid_params, event_id: @event.to_param
        end

        it "should expose a newly created room as @room" do
          extract_valid_params(assigns(:room)).should eq(@valid_params)
        end

        it "should redirect to the rooms index" do
          response.should redirect_to(event_rooms_path(@event))
        end
      end

      describe "with invalid params" do
        before do
          post :create, room: {capacity: 3}, event_id: @event.to_param
        end

        it "should expose a newly created but unsaved room as @room" do
          assigns(:room).should be_new_record
        end

        it "should re-render the 'new' template" do
          response.should render_template('new')
        end

      end

    end

    describe "responding to PUT update" do

      describe "with valid params" do
        before do
          @valid_params = extract_valid_params(@room)
          Room.should_receive(:find).with("37").and_return(@room)
          @room.should_receive(:update_attributes).with(@valid_params).and_return(true)

          put :update, id: "37", room: @valid_params, event_id: @event.to_param
        end

        it "should expose the requested room as @room" do
          assigns(:room).should equal(@room)
        end

        it "should redirect to the room" do
          response.should redirect_to(room_path(@room))
        end

      end

      describe "with invalid params" do
        before do
          @room.should_receive(:update_attributes).and_return(false)
          Room.should_receive(:find).with("37").and_return(@room)

          put :update, id: "37", room: {name: 'hello'}, event_id: @event.to_param
        end

        it "should expose the room as @room" do
          assigns(:room).should equal(@room)
        end

        it "should re-render the 'edit' template" do
          response.should render_template('edit')
        end

      end

    end

    describe "responding to DELETE destroy" do
      before do
        @room.stub(:destroy).and_return(true)
      end

      it "should destroy the requested room" do
        Room.should_receive(:find).with("37").and_return(@room)
        @room.should_receive(:destroy)
        delete :destroy, id: "37", event_id: @event.to_param
      end

      it "should redirect to the rooms list" do
        Room.stub(:find).and_return(@room)
        delete :destroy, id: "1", event_id: @event.to_param
        response.should redirect_to(event_rooms_path(@event))
      end

    end
  end

end
