Rails.application.routes.draw do
  devise_for :admin_users
  root to: "usage_reports#dashboard"
  
  resources :organizations, path: 'instances' do
    member do
      put :restore
    end
  end

  resource :dashboard, only: :show do
  end

  resources :admin_users
  resources :duplications, only: :index do
    put :resolve, on: :member
  end

  resources :release_notes, except: :destroy do
    member do
      put :publish
    end
  end

  resources :billable_reports, only: [:index, :show], path: :finances
  resources :messages, only: [:index]

  resources :usage_reports, only: [:index] do
    collection do
      get :dashboard
    end
  end
end
