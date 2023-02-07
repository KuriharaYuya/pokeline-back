Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :users, path: "/" do
        get "/users/test", to: "users#test"
      end
    end
  end
end
