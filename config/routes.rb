Rails.application.routes.draw do
  resources :notes
  resources :games
  root to: 'games#index'
end
