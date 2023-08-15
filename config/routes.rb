Rails.application.routes.draw do
  # devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  devise_for :admin_users
  root to: "dashboards#show"
  
  resource :dashboard, only: :show do
    resources :organizations
    resources :admin_users
  end
end
