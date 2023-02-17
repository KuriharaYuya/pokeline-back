Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users

      post "/sessions", to: "sessions#create"
      delete "/sessions", to: "sessions#destroy"

      resources :posts
      resources :comments
    end
  end
end
