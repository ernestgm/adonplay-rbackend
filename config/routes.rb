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
      post '/login_device', to: 'authentication#login_device'
      post '/activate_device', to: 'authentication#activate_device'
      post '/logout', to: 'authentication#logout'
      
      # Entity routes
      resources :businesses, only: [:index, :show, :create, :update]
      delete '/businesses', to: 'businesses#destroy' # Bulk delete businesses
      
      resources :devices, only: [:index, :show, :create, :update]
      delete '/devices', to: 'devices#destroy' # Bulk delete devices
      
      resources :marquees, only: [:index, :show, :create, :update]
      delete '/marquees', to: 'marquees#destroy' # Bulk delete marquees
      
      # Media routes
      resources :media, only: [:index, :show, :create, :update]
      get '/media_excepted/:slide_id', to: 'media#index_excepted'
      get '/all_audio_excepted/:slide_id', to: 'media#all_audio_excepted'
      delete '/media', to: 'media#destroy' # Bulk delete media
      
      # Slide Media routes
      resources :slide_media, only: [:show, :create, :update]
      delete '/slide_media', to: 'slide_media#destroy' # Bulk delete media
      
      # Nested routes for slides and media
      resources :slides, only: [:index, :show, :create, :update] do
        resources :media, only: [:index], controller: 'slide_media'
        post '/media/reorder', to: 'slide_media#reorder'
      end
      delete '/slides', to: 'slides#destroy' # Bulk delete slides
      
      
      resources :qrs, only: [:index, :show, :create, :update]
      delete '/qrs', to: 'qrs#destroy' # Bulk delete QRs

      resources :devices_verify_codes, only: [:create]
      post '/create_login_code', to: 'devices_verify_codes#create_login_code'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
