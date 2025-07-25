Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # User routes
      resources :users, only: [:index, :show, :create, :update]
      delete '/users', to: 'users#destroy' # Bulk delete users
      
      # Authentication routes
      post '/login', to: 'authentication#login'
      delete '/logout', to: 'authentication#logout'
      
      # Entity routes
      resources :businesses, only: [:index, :show, :create, :update]
      delete '/businesses', to: 'businesses#destroy' # Bulk delete businesses
      
      resources :devices, only: [:index, :show, :create, :update, :destroy]
      delete '/devices', to: 'devices#destroy' # Bulk delete devices
      
      resources :marquees, only: [:index, :show, :create, :update, :destroy]
      delete '/marquees', to: 'marquees#destroy' # Bulk delete marquees
      
      resources :media, only: [:index, :show, :create, :update, :destroy]
      delete '/media', to: 'media#destroy' # Bulk delete media
      
      resources :playlists, only: [:index, :show, :create, :update, :destroy]
      delete '/playlists', to: 'playlists#destroy' # Bulk delete playlists
      
      resources :qrs, only: [:index, :show, :create, :update, :destroy]
      delete '/qrs', to: 'qrs#destroy' # Bulk delete QRs
      
      resources :slides, only: [:index, :show, :create, :update, :destroy]
      delete '/slides', to: 'slides#destroy' # Bulk delete slides
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
