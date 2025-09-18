Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :frames, only: %i[ show create destroy ] do
    resources :circles, shallow: true, except: %i[ index show ]
  end

  # Recria o endpoint /circles pois por padrão o shallow resource cria o index dentro do /frame
  get "/circles", to: "circles#index"
end
