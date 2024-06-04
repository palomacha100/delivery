Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  resources :stores do
    resources :products
      member do
        put 'active_product', to: 'products#active_product'
        put 'active_store', to: 'stores#active_store'
      end
  end

  mount Rswag::Ui::Engine => "/api-docs", as: :api_ui_docs 
  mount Rswag::Api::Engine => "/api-docs",
  as: :api_docs 
  get "listing" => "products#listing"

  post "new" => "registrations#create", as: :create_registration
  get "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"
  get "sign_in", to: "registrations#new_sign_in"
  post "sign_up", to: "registrations#sign_up"
  get "sign_up", to: "registrations#new"
  get "users", to: "registrations#index"
  delete "destroy", to: "registrations#destroy"
  get "edit", to: "registrations#edit"
  put "edit", to: "registrations#edit_user" 
  put "active", to: "registrations#active"
  get "show", to: "registrations#show"

  post 'refresh', to: 'registrations#refresh'

  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end

  root to: "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check

end
