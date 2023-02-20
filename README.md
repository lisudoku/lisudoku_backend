# lisudoku_backend

Backend URL: https://api.lisudoku.xyz

This is [lisudoku](https://lisudoku.xyz/)'s Rails backend that is consumed by the React [frontend](https://github.com/lisudoku/lisudoku_frontend).

It uses a postgres database.

## Contribute

Contributions are welcome! You can contribute by writing code, providing UI designs, or any idea that can improve lisudoku.

Join the [discord server](https://discord.gg/SGV8TQVSeT).

## Setup

1. Clone the repo
2. Install ruby using [rbenv](https://github.com/rbenv/rbenv) (`.ruby-version` specifies the version)
3. Install postgres ([postgresapp](https://postgresapp.com) for MacOS)
4. Install the bundler `gem install bundler`
5. Install gems `bundle install`
6. Run migrations `rails db:setup`
7. Start the server `rails s`

## Deployment

The backend is deployed on [fly.io](https://fly.io/).

Deployment command: `fly deploy`
