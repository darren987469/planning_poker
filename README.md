# Planning poker

[![CircleCI](https://circleci.com/gh/darren987469/planning_poker/tree/master.svg?style=svg)](https://circleci.com/gh/darren987469/planning_poker/tree/master)

Demo: https://glacial-castle-59975.herokuapp.com/

* Ruby version
```sh
rbenv install 2.7.4
```

* System dependencies
```sh
brew install postgresql
yarn install
```

* Configuration

* Database creation
```sh
bin/rails db:create
bin/rails db:migrate
```

* Development
```sh
bin/rails s # rails server on localhost:3000
bin/webpack-dev-server
```

* How to run the test suite
```sh
bundle exec rspec
```

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

```sh
git push heroku master # master is the branch name

heroku run bash # connect to heroku interactive shell
heroku open # open the app
heroku logs --tail # check logs
heroku addons:open rollbar # exception reporting service
```

Heroku guide: https://devcenter.heroku.com/articles/getting-started-with-rails6
ActionCable on heroku: https://blog.heroku.com/real_time_rails_implementing_websockets_in_rails_5_with_action_cable
