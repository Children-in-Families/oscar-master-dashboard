Rails.application.routes.draw do
  devise_for :admin_users
  root to: "dashboards#show"
  
  resources :organizations, path: 'instances' do
    member do
      put :restore
    end
  end

  resource :dashboard, only: :show do
    get :status_overview
    get :sync_overview
    get :instance_overview
    get :location_overview
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
