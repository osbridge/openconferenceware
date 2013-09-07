OpenConferenceWare::Application.routes.draw do
  resources :comments
  resources :proposals do
    resources :comments
    resource :selector_vote, :only => :create
    match 'login' => 'proposals#proposal_login_required', :as => :login
  end

  match '/proposals/manage_speakers/:id' => 'proposals#manage_speakers', :as => :manage_proposal_speakers, :constraints => { :method => :post }
  match '/proposals/search_speakers/:id' => 'proposals#search_speakers', :as => :search_proposal_speakers, :constraints => { :method => :post }
  match '/proposals/speaker_confirm/:id' => 'proposals#speaker_confirm', :as => :speaker_confirm, :constraints => { :method => :post }
  match '/proposals/speaker_decline/:id' => 'proposals#speaker_decline', :as => :speaker_decline, :constraints => { :method => :post }
  match '/sessions' => 'proposals#sessions_index', :as => :sessions
  match '/schedule' => 'proposals#schedule', :as => :schedule
  match '/sessions/:id' => 'proposals#session_show', :as => :session
  match '/sessions_terse' => 'proposals#sessions_index_terse', :as => :sessions_terse

  resources :events do
    member do
      get :speakers
    end
    resources :proposals do
      collection do
       :stats
      end
    end

    resources :tracks
    resources :session_types
    resources :rooms
    resources :schedule_items
    match '/sessions' => 'proposals#sessions_index', :as => :sessions
    match '/sessions_terse' => 'proposals#sessions_index_terse', :as => :sessions_terse
    match '/schedule' => 'proposals#schedule', :as => :schedule
    match '/sessions/:id' => 'proposals#session_show', :as => :session
    resources :selector_votes, :only => :index
  end

  match '/' => 'events#index'

  namespace :manage do
    resources :events
    resources :snippets
    match '/events/:id/proposals' => 'events#proposals', :as => :event_proposals
    match '/events/:id/notify_speakers' => 'events#notify_speakers', :as => :notify_speakers
  end

  match '/' => 'proposals#proposals_or_sessions'
  match '/br3ak' => 'proposals#br3ak', :as => :br3ak
  match '/m1ss' => 'proposals#m1ss', :as => :m1ss

  resources :users do
    member do
      get :complete_profile
      get :proposals
    end

    match 'favorites.:format' => 'user_favorites#index', :as => :favorites
    match 'favorites/modify.:format' => 'user_favorites#modify', :as => :modify_favorites, :via => :put
  end

  match '/browser_session' => 'browser_sessions#create', :as => :open_id_complete, :constraints => { :method => :get }
  match '/login' => 'browser_sessions#new', :as => :login
  match '/logout' => 'browser_sessions#destroy', :as => :logout
  match '/admin' => 'browser_sessions#admin', :as => :admin

  resource :browser_session do
    collection do
     :admin
    end
  end

  match '/:controller(/:action(/:id))'
end
