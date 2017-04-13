Rails.application.routes.draw do
  namespace :v1 do
    resources :survivors, only: [:create, :show] do
      member do
        put :update_location
        put :report_infected
        put :trade
      end
    end
  end
end
