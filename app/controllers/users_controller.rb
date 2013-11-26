class UsersController < ApplicationController
  before_filter :require_admin unless user_profiles?
  before_filter :assert_user, :only => [:show, :edit, :update, :destroy, :complete_profile, :proposals]
  before_filter :authentication_required, :only => [:edit, :update, :destroy]
  before_filter :assert_record_ownership, :only => [:edit, :update, :destroy]

  def index
    add_breadcrumb 'Users'

    @users = User.order('last_name asc').all

    respond_to do |format|
      format.html # Display index.html.erb for @users
      format.json { render :json => @users }
      format.xml  { render :xml  => @users }
    end
  end

  def show
    respond_to do |format|
      format.html # Display show.html.erb for @user
      format.json { render :json => @user }
      format.xml  { render :xml  => @user }
    end
  end

  def new
    # Display new.html.erb
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new
    @user.assign_attributes(params[:user].slice(*User.accessible_attributes))

    @user.login = params[:user][:login]

    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:success] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def edit
    # Display edit.html.erb for @user

    if params[:require_complete_profile]
      @user.complete_profile = true
    end
  end

  def update
    if admin? or can_edit?(@user)
      if params[:require_complete_profile]
        @user.complete_profile = true
      end

      @user.assign_attributes(
        params[:user].slice(*User.accessible_attributes(current_user.role)),
        :as => current_user.role
      )

      if @user.save
        flash[:success] = "Updated user profile."
        return redirect_back_or_to(user_path(@user))
      else
        flash[:failure] = "Please complete user profile."
        render :action => "edit"
      end
    else
      flash[:failure] = "Sorry, you don't have permission to edit this user: #{@user.label}"
      return redirect_to(users_path)
    end
  end

  def destroy
    if admin? or can_edit?(@user)
      @user.destroy
      flash[:success] = "Deleted user: #{@user.label}"
    else
      flash[:failure] = "Sorry, you don't have permission to delete this user: #{@user.label}"
    end
    return redirect_back_or_to(users_path)
  end

  def complete_profile
    if current_user.complete_profile
      flash[:notice] = "Thank you, you have a complete user profile."
      redirect_to(user_path(current_user))
    else
      flash[:notice] = "Please complete your user profile."
      redirect_to(edit_user_path(current_user, :require_complete_profile => true))
    end
  end

  def proposals
    @proposals = @user.proposals
  end
end
