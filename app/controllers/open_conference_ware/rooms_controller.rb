module OpenConferenceWare
  class RoomsController < ApplicationController
    before_filter :require_admin, only: [:new, :create, :edit, :update, :destroy]
    before_filter :assert_current_event_or_redirect
    before_filter :normalize_event_path_or_redirect, only: [:index]
    before_filter :add_event_breadcrumb
    before_filter :add_rooms_breadcrumb
    before_filter :assign_room, only: [:show, :edit, :update, :destroy]

    # GET /rooms
    # GET /rooms.xml
    def index
      @rooms = @event.rooms

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @rooms }
        format.xml  { render xml: @rooms }
      end
    end

    # GET /rooms/1
    # GET /rooms/1.xml
    def show
      add_breadcrumb @room.name

      unless params[:sort]
        params[:sort] = schedule_visible? ? "start_time" : "title"
      end

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @room }
        format.xml  { render xml: @room }
      end
    end

    # GET /rooms/new
    # GET /rooms/new.xml
    def new
      @room = Room.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @room }
      end
    end

    # GET /rooms/1/edit
    def edit
    end

    # POST /rooms
    # POST /rooms.xml
    def create
      @room = @event.rooms.new(room_params)

      respond_to do |format|
        if @room.save
          flash[:notice] = 'Room was successfully created.'
          format.html { redirect_to(rooms_path) }
          format.xml  { render xml: @room, status: :created, location: @room }
        else
          format.html { render action: "new" }
          format.xml  { render xml: @room.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /rooms/1
    # PUT /rooms/1.xml
    def update
      respond_to do |format|
        if @room.update_attributes(room_params)
          flash[:notice] = 'Room was successfully updated.'
          format.html { redirect_to(@room) }
          format.xml  { head :ok }
        else
          format.html { render action: "edit" }
          format.xml  { render xml: @room.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /rooms/1
    # DELETE /rooms/1.xml
    def destroy
      @room.destroy

      respond_to do |format|
        format.html { redirect_to(rooms_url) }
        format.xml  { head :ok }
      end
    end

    protected

      def room_params
        params.require(:room).permit(
          :name,
          :capacity,
          :size,
          :seating_configuration,
          :description,
          :image,
          :image_file_name,
          :image_content_type,
          :image_file_size,
          :image_updated_at
        ) if admin?
      end

      def add_event_breadcrumb
        add_breadcrumb @event.title, @event
      end

      def add_rooms_breadcrumb
        add_breadcrumb "Rooms", rooms_path
      end

      def assign_room
        begin
          @room = Room.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          flash[:failure] = "Sorry, that room doesn't exist or has been deleted."
          return redirect_to(rooms_path)
        end
      end
  end
end
