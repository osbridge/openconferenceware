ActionController::Routing::Routes.draw do |map|

  # See how all your routes lay out with "rake routes"

  map.resources :comments, :path_prefix => 'proposals'
  map.comments_feed '/proposals/comments.atom', :controller => 'comments', :action => 'index'

  map.resources :proposals do |proposals|
    proposals.resources :comments, :controller => 'comments'
  end
  map.proposals_feed '/proposals.atom', :controller => 'proposals', :action => 'index'

  map.manage_proposal_speakers '/proposals/manage_speakers/:id', :controller => 'proposals', :action => 'manage_speakers', :requirements => { :method => :post }
  map.search_proposal_speakers '/proposals/search_speakers/:id', :controller => 'proposals', :action => 'search_speakers', :requirements => { :method => :post }
  
  map.sessions '/sessions', :controller => 'proposals', :action => 'sessions_index'
  map.schedule '/schedule', :controller => 'proposals', :action => 'schedule'
  map.schedule '/schedule.:format', :controller => 'proposals', :action => 'schedule'
  map.session '/sessions/:id', :controller => 'proposals', :action => 'session_show'
  
  map.resources :events do |events|
    events.resources :proposals, :controller => 'proposals', :collection => 'stats'
    events.resources :tracks, :controller => 'tracks'
    events.resources :session_types
    events.resources :rooms
    events.sessions '/sessions', :controller => 'proposals', :action => 'sessions_index'
    events.schedule '/schedule', :controller => 'proposals', :action => 'schedule'
    events.schedule '/schedule.:format', :controller => 'proposals', :action => 'schedule'
    events.session '/sessions/:id', :controller => 'proposals', :action => 'session_show'
  end

  map.resource :manage, :controller => 'manage' do |manage|
    manage.resources :events, :controller => 'manage/events'
    manage.resources :snippets, :controller => 'manage/snippets'
  end
  map.manage_event_proposals '/manage/events/:id/proposals', :controller => 'manage/events', :action => 'proposals'

  map.root :controller => "proposals"

  # For testing errors
  map.br3ak '/br3ak', :controller => 'proposals', :action => 'br3ak'
  map.m1ss  '/m1ss',  :controller => 'proposals', :action => 'm1ss'

  # Authentication
  map.resources :users, :member => { :complete_profile => :get }, :requirements => { :id => /\w+/ }
  map.open_id_complete '/browser_session', :controller => "browser_sessions", :action => "create", :requirements => { :method => :get }
  map.login            '/login',  :controller => 'browser_sessions', :action => 'new'
  map.logout           '/logout', :controller => 'browser_sessions', :action => 'destroy'
  map.admin            '/admin',  :controller => 'browser_sessions', :action => 'admin'
  map.resource  :browser_session, :collection => ["admin"]

  # Install the default routes as the lowest priority.
  # TODO Disable default routes, they're dangerous.
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
