Rails.application.routes.draw do
  resources :wanted_domains

  root to: 'wanted_domains#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
