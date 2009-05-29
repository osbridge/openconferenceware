class UserFavoritesController < ApplicationController
  before_filter :assert_user
  before_filter :login_required, :only => :modify
  before_filter :assert_record_ownership, :only => :modify

  # GET /favorites
  # GET /favorites.xml
  # GET /favorites.json
  def index
    # TODO Document what :join does or remove it.
    if params[:join] == "1"
      @user_favorites = UserFavorite.find_all_by_user_id(@user.id)
    else
      @user_favorites = @user.favorites
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_favorites }
      format.json  { render :json => @user_favorites }
      format.ics {
        calendar = Vpim::Icalendar.create2
        @user_favorites.scheduled.each do |item|
          calendar.add_event do |e|
            e.dtstart     item.start_time
            e.dtend       item.start_time + item.duration.minutes
            e.summary     item.title
            e.created     item.created_at if item.created_at
            e.lastmod     item.updated_at if item.updated_at
            e.description item.excerpt
            e.url         session_url(item)
            e.set_text    'LOCATION', item.room.name if item.room
          end
        end
        calendar.encode.sub(/CALSCALE:Gregorian/, "CALSCALE:Gregorian\nX-WR-CALNAME:#{@user.possessive_label(false)} favorites\nMETHOD:PUBLISH")

        render :text => calendar
      }
    end
  end

  # PUT /favorites/1.xml
  # PUT /favorites/1.json
  def modify
    unless params[:proposal_id].blank? || params[:mode].blank? || !['add','remove'].include?(params[:mode])
      @user_favorite = \
        case params[:mode]
        when 'add'
          UserFavorite.add(@user.id, params[:proposal_id])
        when 'remove'
          UserFavorite.remove(@user.id, params[:proposal_id])
        end

      respond_to do |format|
        format.xml  { head :ok }
        format.json  { render :json => @user_favorite }
      end
    else
      errors = {:error => 'Malformed request.'}
      respond_to do |format|
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
        format.json  { render :json => errors, :status => :unprocessable_entity }
      end
    end
  end

end
