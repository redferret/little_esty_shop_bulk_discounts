Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope module: :merchants do
    resources :merchants, only: [ :show  ] do
      resources :dashboard, only: [ :index ]
      resources :items, except: [ :destroy ]
      resources :item_status, only: [ :update ]
      resources :invoices, only: [ :index, :show, :update ]
      resources :bulk_discounts, only: [ :index ]
    end
  end

  namespace :admin do
    resources :dashboard, only: [ :index ]
    resources :merchants, except: [ :destroy ]
    resources :merchant_status, only: [ :update ]
    resources :invoices, except: [ :new, :destroy ]
  end
end
