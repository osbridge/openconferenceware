OpenConferenceWare::Application.routes.draw do
  get "/sign_in" => "authentications#sign_in", as: :sign_in
  get "/sign_out" => "authentications#sign_out", as: :sign_out

  get '/auth/:provider/callback' => 'authentications#create'
  get '/auth/failure' => 'authentications#failure'

  resources :authentications, only: [:create]

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
    get '/sessions' => 'proposals#sessions_index', as: :sessions
    get '/sessions_terse' => 'proposals#sessions_index_terse', as: :sessions_terse
    get '/schedule' => 'proposals#schedule', as: :schedule
    get '/sessions/:id' => 'proposals#session_show', as: :session
    resources :selector_votes, only: :index
  end

  namespace :manage do
    resources :events
    resources :snippets
    get '/events/:id/proposals' => 'events#proposals', as: :event_proposals
    post '/events/:id/notify_speakers' => 'events#notify_speakers', as: :notify_speakers
  end

  resources :comments, only: [:index, :destroy]
  resources :proposals do
    resources :comments
    resource :selector_vote, only: :create
    get 'login' => 'proposals#proposal_login_required', as: :login
  end

  post '/proposals/manage_speakers/:id' => 'proposals#manage_speakers', as: :manage_proposal_speakers
  post '/proposals/search_speakers/:id' => 'proposals#search_speakers', as: :search_proposal_speakers
  post '/proposals/speaker_confirm/:id' => 'proposals#speaker_confirm', as: :speaker_confirm
  post '/proposals/speaker_decline/:id' => 'proposals#speaker_decline', as: :speaker_decline
  get '/sessions' => 'proposals#sessions_index', as: :sessions
  get '/schedule' => 'proposals#schedule', as: :schedule
  get '/sessions/:id' => 'proposals#session_show', as: :session
  get '/sessions_terse' => 'proposals#sessions_index_terse', as: :sessions_terse

  get '/' => 'proposals#proposals_or_sessions'
  get '/br3ak' => 'proposals#br3ak', as: :br3ak
  get '/m1ss' => 'proposals#m1ss', as: :m1ss

  resources :users, constraints: { id: /\w+/ } do
    member do
      get :complete_profile
      get :proposals
    end

    get 'favorites' => 'user_favorites#index', as: :favorites
    put 'favorites/modify' => 'user_favorites#modify', as: :modify_favorites
  end

  resources :session_types, only: [:index]
  resources :tracks, only: [:index]
  resources :rooms, only: [:index]
  resources :selector_votes, only: [:index]

  root to: 'events#index'
end
