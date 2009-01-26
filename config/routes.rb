ActionController::Routing::Routes.draw do |map|

  # See how all your routes lay out with "rake routes"

  map.resources :proposals do |proposals|
    proposals.resources :comments, :controller => 'comments'
  end
  map.proposals_feed '/proposals.atom', :controller => 'proposals', :action => 'index'

  map.manage_proposal_speakers '/proposals/manage_speakers/:id', :controller => 'proposals', :action => 'manage_speakers'
  map.search_proposal_speakers '/proposals/search_speakers/:id', :controller => 'proposals', :action => 'search_speakers'

  map.resources :comments
  map.comments_feed '/comments.atom', :controller => 'comments', :action => 'index'

  map.resources :events do |events|
    events.resources :proposals, :controller => 'proposals'
    events.resources :tracks, :controller => 'tracks'
    events.resources :session_types
  end

  map.resource :manage, :controller => 'manage' do |manage|
    manage.resources :events, :controller => 'manage/events'
    manage.resources :snippets, :controller => 'manage/snippets'
  end

  map.root :controller => "proposals"

  # For testing errors
  map.br3ak '/br3ak', :controller => 'proposals', :action => 'br3ak'
  map.m1ss  '/m1ss',  :controller => 'proposals', :action => 'm1ss'

  # Authentication
  map.resources :users
  map.resource  :session, :collection => ["admin"]
  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.login            '/login',  :controller => 'sessions', :action => 'new'
  map.logout           '/logout', :controller => 'sessions', :action => 'destroy'
  map.admin            '/admin',  :controller => 'sessions', :action => 'admin'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

# {{{
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
# }}}
end
