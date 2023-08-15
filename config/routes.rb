Rails.application.routes.draw do
  get 'usage_reports/index'
  get 'finances/index'
  get 'duplications/index'
  get 'admin_users/index'
  get 'organizations/index'
  # devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  devise_for :admin_users
  root to: "dashboards#show"
  
  resource :dashboard, only: :show
  resources :organizations, path: 'instances'
  resources :admin_users
  resources :duplications
  resources :finances
  resources :usage_reports
end
