Rails.application.routes.draw do
  namespace :api do
    resources :puzzles, only: %i[show] do
      collection do
        get 'random'
      end
      member do
        post 'check'
      end
    end
  end
end
