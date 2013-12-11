module OpenConferenceWare
  class ScheduleItemsController < ApplicationController
    before_filter :require_admin, only: [:new, :create, :edit, :update, :destroy]
    before_filter :assert_current_event_or_redirect
    before_filter :normalize_event_path_or_redirect, only: [:index]
    before_filter :add_event_breadcrumb
    before_filter :add_schedule_items_breadcrumb
    before_filter :assign_schedule_item, only: [:show, :edit, :update, :destroy]

    # GET /schedule_items
    # GET /schedule_items.xml
    def index
      @schedule_items = @event.schedule_items.order('start_time ASC')

      respond_to do |format|
        format.html # index.html.erb
        format.json  { render json: @schedule_items }
        format.xml   { render xml: @schedule_items }
      end
    end

    # GET /schedule_items/1
    # GET /schedule_items/1.xml
    def show
      add_breadcrumb @schedule_item.title

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @schedule_item }
        format.xml  { render xml: @schedule_item }
      end
    end

    # GET /schedule_items/new
    # GET /schedule_items/new.xml
    def new
      @schedule_item = ScheduleItem.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @schedule_item }
        format.xml  { render xml: @schedule_item }
      end
    end

    # GET /schedule_items/1/edit
    def edit
    end

    # POST /schedule_items
    # POST /schedule_items.xml
    def create
      @schedule_item = @event.schedule_items.new(schedule_item_params)

      respond_to do |format|
        if @schedule_item.save
          flash[:notice] = 'ScheduleItem was successfully created.'
          format.html { redirect_to(@schedule_item) }
          format.json { render json: @schedule_item, status: :created, location: @schedule_item }
          format.xml  { render xml: @schedule_item, status: :created, location: @schedule_item }
        else
          format.html { render action: "new" }
          format.json { render json: @schedule_item.errors, status: :unprocessable_entity }
          format.xml  { render xml: @schedule_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /schedule_items/1
    # PUT /schedule_items/1.xml
    def update
      respond_to do |format|
        if @schedule_item.update_attributes(schedule_item_params)
          flash[:notice] = 'ScheduleItem was successfully updated.'
          format.html { redirect_to(@schedule_item) }
          format.json  { head :ok }
          format.xml   { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @schedule_item.errors, status: :unprocessable_entity }
          format.xml  { render xml: @schedule_item.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /schedule_items/1
    # DELETE /schedule_items/1.xml
    def destroy
      @schedule_item.destroy

      respond_to do |format|
        format.html { redirect_to(schedule_items_url) }
        format.json { head :ok }
        format.xml  { head :ok }
      end
    end

    protected

      def schedule_item_params
        params.require(:schedule_item).permit(
          :title,
          :description,
          :excerpt,
          :start_time,
          :duration,
          :room_id
        ) if admin?
      end

      def add_event_breadcrumb
        add_breadcrumb @event.title, @event
      end

      def add_schedule_items_breadcrumb
        add_breadcrumb "Schedule Items", schedule_items_path
      end

      def assign_schedule_item
        begin
          @schedule_item = ScheduleItem.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          flash[:failure] = "Sorry, that schedule item doesn't exist or has been deleted."
          return redirect_to(schedule_items_path)
        end
      end
  end
end
