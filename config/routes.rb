Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # resources :users, only: [:create]
  post 'sign-up', to: "users#create"
  post 'login', to: "authentication#login"
  resources :pets, only: [:index, :create]
end
