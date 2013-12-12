module OpenConferenceWare
  module Manage
    class SnippetsController < ApplicationController
      before_filter :require_admin

      include BreadcrumbsMixin
      add_breadcrumb "Manage", "/manage"
      add_breadcrumb "Snippets", "/manage/snippets/"

      # GET /snippets
      # GET /snippets.xml
      def index
        @snippets = Snippet.order(:slug).where(public: true)

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render xml: @snippets }
        end
      end

      # GET /snippets/1
      # GET /snippets/1.xml
      def show
        @snippet = Snippet.find(params[:id])
        add_breadcrumb @snippet.slug, manage_snippet_path(@snippet)

        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render xml: @snippet }
        end
      end

      # GET /snippets/new
      # GET /snippets/new.xml
      def new
        @snippet = Snippet.new

        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render xml: @snippet }
        end
      end

      # GET /snippets/1/edit
      def edit
        @snippet = Snippet.find(params[:id])
        add_breadcrumb @snippet.slug, manage_snippet_path(@snippet)

        @return_to = params[:return_to] || request.env["HTTP_REFERER"]
      end

      # POST /snippets
      # POST /snippets.xml
      def create
        @snippet = Snippet.new(snippet_params)

        respond_to do |format|
          if @snippet.save
            flash[:notice] = 'Snippet was successfully created.'
            format.html { redirect_to([:manage, @snippet]) }
            format.xml  { render xml: @snippet, status: :created, location: @snippet }
          else
            format.html { render action: "new" }
            format.xml  { render xml: @snippet.errors, status: :unprocessable_entity }
          end
        end
      end

      # PUT /snippets/1
      # PUT /snippets/1.xml
      def update
        @snippet = Snippet.find(params[:id])
        add_breadcrumb @snippet.slug, manage_snippet_path(@snippet)

        @return_to = params[:return_to]

        respond_to do |format|
          if @snippet.update_attributes(snippet_params)
            flash[:notice] = 'Snippet was successfully updated.'
            format.html { redirect_to(@return_to ? @return_to : [:manage, @snippet]) }
            format.xml  { head :ok }
          else
            format.html { render action: "edit" }
            format.xml  { render xml: @snippet.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /snippets/1
      # DELETE /snippets/1.xml
      def destroy
        @snippet = Snippet.find(params[:id])
        @snippet.destroy

        respond_to do |format|
          format.html { redirect_to manage_snippets_path, :flash => {:success => "Snippet was deleted."} }
          format.xml  { head :ok }
        end
      end

      private

        def snippet_params
          params.require(:snippet).permit(
            :slug, :description, :content, :value, :public
          ) if admin?
        end
    end
  end
end
