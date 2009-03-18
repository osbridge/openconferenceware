class CommentsController < ApplicationController

  SECRET = SECRETS.comments_secret # DEPENDENCY: lib/secrets_reader.rb

  MAX_FEED_ITEMS = 50

  before_filter :require_admin, :except => [:index, :create]

  def index
    @comments = Comment.listable
    add_breadcrumb "Comments", comments_path()

    case request.format.to_sym
    when :atom, :json, :xml
      unless params[:secret] == SECRET
        render(:text => "403 Forbidden: You can't see the comments feed unless you supply the secret key", :status => 403) and return
      end
      @comments = @comments[0..MAX_FEED_ITEMS]
    else
      require_admin() or return
    end

    respond_to do |format|
      format.html  # index.html.erb
      format.atom
    end
  end

  # This is a weird action. The form is part of the proposals#show page, so errors and successes both go back to that page.
  def create
    unless params[:quagmire].blank?
      flash[:failure] = "Comment rejected because you're behaving like a robot, please leave the 'Leave blank' field blank."
      redirect_to(:back) rescue redirect_to proposals_path()
      return
    end

    @comment = Comment.new(params[:comment])
    unless @comment.proposal_id
      flash[:failure] = "Can't add comment to non-existant proposal"
      redirect_to(:back) rescue redirect_to(events_path)
      return
    end

    # Use session to store email address and prefill it as needed
    if @comment.email.blank?
      @comment.email = current_email
    else
      session[:email] = @comment.email
    end

    respond_to do |format|
      if @comment.save
        flash[:success] = "Comment added."
        format.html { redirect_to(proposal_path(@comment.proposal, :commented => true)) }
        format.xml  { render :xml  => @comment, :status => :created }
        format.json { render :json => @comment, :status => :created }
      else
        @display_comment_form = true
        @focus_comment = true
        if @proposal = @comment.proposal
          flash[:failure] = "Invalid comment."
        else
          flash[:failure] = "Can't add comment to invalid proposal."
          flash.keep
          return redirect_to(proposals_path)
        end
        format.html { render :template => "proposals/show" }
        format.xml  { render :xml  => @comment.errors, :status => :unprocessable_entity }
        format.json { render :json => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:success] = "Destroyed comment: #{@comment.id}"

    respond_to do |format|
      format.html {
        redirect_to(:back) rescue redirect_to(comments_path)
      }
    end
  end
end
