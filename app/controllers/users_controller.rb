class UsersController < ApplicationController
  before_filter :require_admin unless user_profiles?

  before_filter :require_user, :only => [:show, :edit, :update, :destroy]

  def index
    add_breadcrumb 'Users'

    @users = User.find(:all, :order => 'last_name asc')
  end

  def show
    # Display show.html.erb for @user
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
    @user = User.new(params[:user])
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
      if admin?
        @user.login            = params[:user][:login]
        @user.admin            = params[:user][:admin]
        @user.complete_profile = params[:user][:complete_profile]
      end

      if params[:require_complete_profile]
        @user.complete_profile = true
      end

      if @user.update_attributes(params[:user])
        flash[:success] = "Updated user."
        return redirect_back_or_to(user_path(@user))
      else
        flash[:failure] = "Please complete your profile."
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

protected

  # Sets @user based on params[:id] and adds related breadcrumbs.
  def require_user
    if params[:id] == "me"
      if logged_in?
        @user = current_user
      else
        return access_denied(:message => "Please login to access your user profile.")
      end
    else
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:failure] = "User not found or deleted"
        return redirect_to(users_path)
      end
    end

    add_breadcrumb "Users", users_path
    add_breadcrumb @user.label, user_path(@user)
    add_breadcrumb "Edit" if ["edit", "update"].include?(action_name)
  end

end
