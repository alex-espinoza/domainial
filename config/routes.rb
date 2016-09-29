Rails.application.routes.draw do
  get 'wanted_domains/check_all', to: 'wanted_domains#check_all'
  resources :wanted_domains

  root to: 'wanted_domains#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
