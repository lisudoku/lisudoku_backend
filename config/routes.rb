require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  root 'application#index'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users,
    controllers: {
      sessions: 'api/sessions',
      registrations: 'api/registrations',
    },
    path_names: {
      sign_in: 'login',
    },
    path: 'api/users',
    skip: :passwords

  namespace :api do
    resources :puzzles, only: %i[show create index destroy update] do
      collection do
        post 'random'
        post 'download'
        get 'group_counts'
      end
      member do
        post 'check'
      end
    end
    resources :trainer_puzzles, only: [] do
      collection do
        post 'random'
      end
    end
    resources :puzzle_collections, only: %i[index create show destroy update] do
      member do
        post 'puzzles', to: 'puzzle_collections#add_puzzle'
        delete 'puzzles/:puzzle_id', to: 'puzzle_collections#remove_puzzle'
      end
    end
    resources :competitions, only: %i[index create show destroy update]
  end
end
