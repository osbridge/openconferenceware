module OpenConferenceWare
  class TracksController < ApplicationController
    before_filter :require_admin, only: [:new, :create, :edit, :update, :destroy]
    before_filter :assert_current_event_or_redirect
    before_filter :normalize_event_path_or_redirect, only: [:index]
    before_filter :add_event_breadcrumb
    before_filter :add_tracks_breadcrumb
    before_filter :assign_track, only: [:show, :edit, :update, :destroy]

    # GET /tracks
    # GET /tracks.xml
    def index
      @tracks = @event.tracks.order("title ASC")

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tracks }
        format.xml  { render xml: @tracks }
      end
    end

    # GET /tracks/1
    # GET /tracks/1.xml
    def show
      add_breadcrumb @track.title

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @track }
        format.xml  { render xml: @track }
      end
    end

    # GET /tracks/new
    # GET /tracks/new.xml
    def new
      @track = Track.new(color: '#666666')

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @track }
      end
    end

    # GET /tracks/1/edit
    def edit
    end

    # POST /tracks
    # POST /tracks.xml
    def create
      @track = @event.tracks.new(track_params)

      respond_to do |format|
        if @track.save
          flash[:success] = 'Track was successfully created.'
          format.html { redirect_to(tracks_path) }
          format.xml  { render xml: @track, status: :created, location: @track }
        else
          format.html { render action: "new" }
          format.xml  { render xml: @track.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /tracks/1
    # PUT /tracks/1.xml
    def update
      respond_to do |format|
        if @track.update_attributes(track_params)
          flash[:success] = 'Track was successfully updated.'
          format.html { redirect_to(track_path(@track)) }
          format.xml  { head :ok }
        else
          format.html { render action: "edit" }
          format.xml  { render xml: @track.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /tracks/1
    # DELETE /tracks/1.xml
    def destroy
      @track.destroy

      respond_to do |format|
        format.html { redirect_to(tracks_path) }
        format.xml  { head :ok }
      end
    end

  protected

    def track_params
      params.require(:track).permit(
        :title, :description, :color, :excerpt
      ) if admin?
    end

    def add_event_breadcrumb
      add_breadcrumb @event.title, @event
    end

    def add_tracks_breadcrumb
      add_breadcrumb "Tracks", tracks_path
    end

    def assign_track
      begin
        @track = Track.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:failure] = "Sorry, that track doesn't exist or has been deleted."
        return redirect_to(tracks_path)
      end
    end

  end
end
