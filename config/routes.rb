Rails.application.routes.draw do
  apipie
  namespace :v1 do
    resources :survivors, only: [:create, :show] do
      member do
        put :update_location
        put :report_infected
        put :trade
      end
    end

    resources :reports, only: [] do
      collection do
        get :infected_survivors
        get :non_infected_survivors
        get :resource_average_by_survivor
        get :points_lost_by_infection
      end
    end
  end

  root 'apipie/apipies#index'
end
