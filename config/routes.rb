Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :actions, only: [:index, :create, :update, :destroy]
  resources :calls, only: [:show, :create, :update, :destroy]
  resources :call_lists, only: [:show, :create, :update, :destroy]
  resources :campaigns, only: [:index, :create, :update, :destroy]
  resources :legislators, only: :index
  resources :committees, only: :index
  resources :notes, only: [:create, :update]

  post '/signup', to: 'users#create'
  get '/users', to: 'users#index'

  post '/login', to: 'auth#login'
  get '/auto_login', to: 'auth#auto_login'

end
