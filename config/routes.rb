require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resource :cart, only: [:create, :show, :destroy] do
    post :add_item, on: :collection
    delete ':product_id', to: 'carts#remove_item', on: :collection
  end
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
