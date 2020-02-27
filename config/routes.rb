Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :actions, only: [:index, :create, :update, :delete]
  resources :calls, only: [:show, :create, :update, :delete]
  resources :call_lists, only: [:show, :create, :update, :delete]
  resources :campaigns, only: [:index, :create, :update, :delete]
  resources :legislators, only: :index

  post '/signup', to: 'users#create'
  post '/login', to: 'auth#login'
  get '/auto_login', to: 'auth#auto_login'

end
