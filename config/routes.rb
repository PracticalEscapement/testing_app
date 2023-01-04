Rails.application.routes.draw do
  root to: 'home#index'

  namespace :api do
    resources :users, only: [:index, :update, :create, :destroy]
    post '/login', to: 'authentication#login'
  end
  
  
end
