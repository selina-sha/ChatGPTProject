Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#index"
  resources :users do
    resources :comments
  end
  get "/users", to: "users#index"
  post "/users/new", to: "users#create"
  get '/users/:id/rating', to: 'users#rating', as: "user_rating"
  post '/users/:id/rating/save_rating', to: 'users#save_rating', as: 'save_rating'
end
