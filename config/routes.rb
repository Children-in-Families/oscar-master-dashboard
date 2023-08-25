Rails.application.routes.draw do
  devise_for :admin_users
  root to: "dashboards#show"
  
  resource :dashboard, only: :show
  
  resources :organizations, path: 'instances' do
    member do
      put :restore
    end
  end

  resources :admin_users
  resources :duplications
  resources :finances

  resources :usage_reports, only: [:show], constraints: { id: /added_cases|synced_cases|cross_referral_oscar|cross_referral_from_primero|cross_referral_to_primero/ }
end
