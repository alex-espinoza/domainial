require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  post 'dictionaries/search', to: 'dictionaries#search'
  resources :dictionaries, only: [:index]

  get 'wanted_domains/expiring_within_month', to: 'wanted_domains#expiring_within_month'
  get 'wanted_domains/check_all', to: 'wanted_domains#check_all'
  get 'wanted_domains/all', to: 'wanted_domains#all'
  resources :wanted_domains, only: [:index, :show, :new, :create]

  namespace :api, defaults: {format: :json} do
    post 'wanted_domains/create', to: 'wanted_domains#create'
    post 'wanted_domains/interested', to: 'wanted_domains#interested'
  end

  root to: 'wanted_domains#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
