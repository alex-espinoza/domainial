require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  post 'dictionaries/search', to: 'dictionaries#search'
  resources :dictionaries

  get 'wanted_domains/check_all', to: 'wanted_domains#check_all'
  get 'wanted_domains/all', to: 'wanted_domains#all'
  resources :wanted_domains

  root to: 'wanted_domains#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
