Rails.application.routes.draw do
  root "admin/dashboard#index"

  get "/login", to: "admin/sessions#new"
  post "/login", to: "admin/sessions#create"
  delete "/logout", to: "admin/sessions#destroy"

  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resources :customers do
      member do
        patch :extend_subscription
        patch :toggle_status
        post :assign_new_key
      end
    end
    resources :groq_keys, only: %i[index new create show update] do
      member do
        patch :reassign
      end
    end
  end

  namespace :api, defaults: { format: :json } do
    post :activate, to: "licenses#activate"
    post "assign-key", to: "licenses#activate"
    post "refresh-key", to: "licenses#refresh_key"
    get :validate, to: "licenses#validate_license"
    post "register-device", to: "licenses#register_device"
  end

  post "/assign-key", to: "api/licenses#activate", defaults: { format: :json }
  post "/refresh-key", to: "api/licenses#refresh_key", defaults: { format: :json }
  get "/validate", to: "api/licenses#validate_license", defaults: { format: :json }
end
