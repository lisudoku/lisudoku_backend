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
    resources :puzzles, only: %i[show create index destroy] do
      collection do
        post 'random'
        get 'group_counts'
      end
      member do
        post 'check'
      end
    end
  end
end
