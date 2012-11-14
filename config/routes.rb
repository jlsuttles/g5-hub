G5Hub::Application.routes.draw do

  resources :features
  resources :locations, except: [:index]
  resources :customers

  match 'admin/edit' => 'admins#edit', :as => :edit_current_admin
  match 'signup' => 'admins#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login

  resources :sessions
  resources :admins

  root to: "customers#index"
end
