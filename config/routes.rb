VpeekerChannels::Application.routes.draw do

  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks",
                                   registrations: "registrations"}

  constraints(Subdomain) do
    match '/' => 'channels#show', :as => 'subdomain_channel'
    match '/videos' => 'videos#index', :as => 'subdomain_channel_videos'
    match '/embed' => 'channels#embed', :as => 'subdomain_embed_channel'
  end

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  match '/auth/twitter/callback' => 'sessions#create'
  match '/signout' => 'sessions#destroy'

  match '/sign-up' => 'info#signup', :as => "signup"
  match '/terms' => 'info#terms', :as => "terms"
  
  namespace 'export' do
    match ':action'
  end

  resources :channels do
    member do
      get 'moderate'
      get 'embed'
    end
    
    resources :videos, only: [:index] do
      member do
        post 'approve'
        post 'deny'
      end
    end
  end

  resources :subscriptions, only: [] do
    collection do
      post :activate
      post :deactivate
      post :changed
    end
  end

  root to: "info#landing"
end
