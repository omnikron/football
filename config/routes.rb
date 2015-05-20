Rails.application.routes.draw do
  resources :games do
    resources :notes
  end

  root to: 'games#index'
end
