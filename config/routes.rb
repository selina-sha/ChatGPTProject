Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#index"
  resources :users do
    resources :ratings
  end
  # resources :users
  get "/users", to: "users#index"
  post "/users/new", to: "users#create", as: "user_create"
  post '/users/:user_id/ratings/save_rating', to: 'ratings#save_rating', as: 'save_rating'
end
