Rails.application.routes.draw do
  namespace :api do
    resources :puzzles, only: %i[show create index destroy] do
      collection do
        get 'random'
      end
      member do
        post 'check'
      end
    end
    namespace :admin do
      get 'puzzle_counts'
    end
  end
end
