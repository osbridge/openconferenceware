class ScheduleItemsController < ApplicationController
  # GET /schedule_items
  # GET /schedule_items.xml
  def index
    @schedule_items = ScheduleItem.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedule_items }
    end
  end

  # GET /schedule_items/1
  # GET /schedule_items/1.xml
  def show
    @schedule_item = ScheduleItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @schedule_item }
    end
  end

  # GET /schedule_items/new
  # GET /schedule_items/new.xml
  def new
    @schedule_item = ScheduleItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @schedule_item }
    end
  end

  # GET /schedule_items/1/edit
  def edit
    @schedule_item = ScheduleItem.find(params[:id])
  end

  # POST /schedule_items
  # POST /schedule_items.xml
  def create
    @schedule_item = ScheduleItem.new(params[:schedule_item])

    respond_to do |format|
      if @schedule_item.save
        flash[:notice] = 'ScheduleItem was successfully created.'
        format.html { redirect_to(@schedule_item) }
        format.xml  { render :xml => @schedule_item, :status => :created, :location => @schedule_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @schedule_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedule_items/1
  # PUT /schedule_items/1.xml
  def update
    @schedule_item = ScheduleItem.find(params[:id])

    respond_to do |format|
      if @schedule_item.update_attributes(params[:schedule_item])
        flash[:notice] = 'ScheduleItem was successfully updated.'
        format.html { redirect_to(@schedule_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @schedule_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedule_items/1
  # DELETE /schedule_items/1.xml
  def destroy
    @schedule_item = ScheduleItem.find(params[:id])
    @schedule_item.destroy

    respond_to do |format|
      format.html { redirect_to(schedule_items_url) }
      format.xml  { head :ok }
    end
  end
end
