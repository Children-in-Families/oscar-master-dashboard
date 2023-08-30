Rails.application.routes.draw do
  devise_for :admin_users
  root to: "usage_reports#dashboard"
  
  resources :organizations, path: 'instances' do
    member do
      put :restore
    end
  end

  resources :admin_users
  resources :duplications
  resources :finances
  resources :messages, only: [:index]

  resources :usage_reports, only: [:index] do
    collection do
      get :dashboard
    end
  end
end
