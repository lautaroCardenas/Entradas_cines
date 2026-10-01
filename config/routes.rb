Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :admin do
    root "dashboard#show"

    resources :cinemas
    resources :halls do
      resources :seats, only: :update
    end
    resources :movies
    resources :screenings
    resources :orders, except: %i[edit update] do
      member do
        patch :pay
        patch :cancel
      end
    end
    resources :users
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      resources :users, only: :create
      get "profile", to: "users#profile"

      resources :cinemas, only: :index
      resources :movies, only: %i[index show]
      resources :screenings, only: :show
      resources :orders, only: %i[index show create] do
        member do
          patch :pay
          patch :cancel
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end
