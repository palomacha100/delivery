Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users
  resources :stores
  mount Rswag::Ui::Engine => "/api-docs", as: :api_ui_docs 
  mount Rswag::Api::Engine => "/api-docs",
  as: :api_docs 
  get "listing" => "products#listing"

  post "new" => "registrations#create", as: :create_registration
  get "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"

  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end

  root to: "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check

end
