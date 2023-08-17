Rails.application.routes.draw do
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

  resources :usage_reports, only: [:show], constraints: { id: /added_cases|synced_cases|cross_referral_oscar|cross_referral_primero/ }
end
