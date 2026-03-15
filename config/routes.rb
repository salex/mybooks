Rails.application.routes.draw do
  resources :splits, only: [:show]
  namespace :bank_statement do
    resource :import, only: [:show]
    resource :update, only: [:show, :update]
  end


  resources :bank_transactions do
    collection do
      get :preview
      patch :new_import
      post :upload_file
      get :import
      get :import_create
    end
    member do 
      get :link
      get :set_link
    end
  end
 
  resources :bank_statements do
    collection do
      post :upload_file
      get :import
    end

    member do 
      get :reconcile
      patch :reconciled
    end
  end

  namespace :vfw do
    resources :post, only: [:index] do
      member do 
        get :voucher
        get :quarter
      end  
    end
  end

  resources :audits  do
    member do 
      get :print
    end
  end


  # resource :about, except:[:edit,:new, :destroy, :show] do
  #   member do 
  #     get 'accounts'
  #     get 'entries'
  #     get 'banking'
  #     get 'reports'
  #     get 'checking'
  #     get 'about'
  #   end
  # end

  resource :session
  resources :passwords, param: :token

  resources :accounts do
    member do 
      get :new_child
      patch :filter
    end
    collection do
      get :index_table
    end
  end

  # resources :books
  namespace :books do
    # resources :importyaml, only: [:new,:create]
    # resources :open, only: :show
    resources :setup do
      get :preview
      get :create 
    end
  
    # , only: [:show, :index, :edit, :new]
  end
  resources :books do 
    member do 
      get :open
    end
  end

  resources :users
  resources :clients

  
  namespace :entries do
    resources :duplicate, only: [:show]
    resources :void, only: [:show, :update]
    resources :search, only: [:edit, :update]
    resources :filter, only: [:index] 
    resources :filtered, only: [:index,:update]
    resources :auto_search, only: :index
  end

  resources :entries do 
    # TODO not used delete at some 
    member do 
      get :link 
      get :new_bt
      patch :new_entry
    end
  end

  namespace :accounts do
    resources :register_pdf, only: :show
    resources :split_register_pdf, only: :show
  end

  resources :reports, only: :index do
    collection do
      get :profit_loss
      get :trial_balance
      # get :checking_balance
      get :register_pdf
      get :split_register_pdf
      get :summary
      patch :set_acct
      get :set_acct

    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  get "dashboard", to: "home#dashboard"
  get "home", to: "home#index"
  get 'vfw', to: 'vfw/post#index', as: 'vfw'
  get 'about/about'
  get 'about/accounts'
  get 'about/entries'
  get 'about/banking'
  get 'about/reports'
  get 'about/checking'
  get 'about', to: 'about#about'

  root "home#index"
end
