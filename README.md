# Rootstrap Pull request to Slack

[![CircleCI](https://circleci.com/gh/rootstrap/pull_requests_to_slack?style=svg)](https://circleci.com/gh/rootstrap/pull_requests_to_slack)
[![Maintainability](https://api.codeclimate.com/v1/badges/b3ba3fcae655ad6f4a21/maintainability)](https://codeclimate.com/github/rootstrap/github_for_slack/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b3ba3fcae655ad6f4a21/test_coverage)](https://codeclimate.com/github/rootstrap/github_for_slack/test_coverage)

Send Github pull request notifications to Slack. 

- Each time a PR is created in your organization it will send a message to a specific Slack channel with a link to the PR and the technology emoji used.
- When the PR is merged it will add a merged reaction emoji.
<img width="459" alt="Screen Shot 2019-08-02 at 11 06 30 AM" src="https://user-images.githubusercontent.com/5280619/62378286-dcd16b80-b51a-11e9-8c31-09c656bb7616.png">


- You can add ``` \slack `This is a small pr @slack_user` ``` at the end of the PR's description to add a message to the notification and to notify specific slack users.
<img width="748" alt="Screen Shot 2019-08-02 at 11 11 30 AM" src="https://user-images.githubusercontent.com/5280619/62378267-d3480380-b51a-11e9-8b1c-2ff31a30de9d.png">

 Make sure to use ``` ` ` ``` in the message in case the slack user name is the same a someone github name, so the github user is not notified.
<img width="797" alt="Screen Shot 2019-08-02 at 11 54 58 AM" src="https://user-images.githubusercontent.com/5280619/62379042-806f4b80-b51c-11e9-9aa9-250a41429c08.png">


- It will not send a notification if the PR is a draft
- It will remove the notification if the PR has an `ON HOLD` and resend the notification when the label is removed.


## Installation

1. Clone this repo
2. Install PostgreSQL in case you don't have it
3. Create your `database.yml` and `application.yml` files. There are sample files in `/config`
4. `bundle install`
5. Generate a secret key with `rake secret` and paste this value into the `application.yml`.
6. Fill the `SLACK_API_TOKEN` and `SLACK_BOT_TOKEN` in `application.yml`.
To get the credentials: log in to https://api.slack.com/apps, select your application and then click OAuth Tokens & Redirect URLs. `SLACK_API_TOKEN` is the `OAuth Access Token` and `SLACK_BOT_TOKEN` is `Bot User OAuth Access Token`
6. `rails db:create`
7. `rails db:migrate`
8. `rails db:seed`  # this will create an admin with admin@example.com:password
9. `npm install -g ngrok` Install Ngrok
10. `rspec` and make sure all tests pass
11. `rails s`
12. You are ready!

## How to test the webhook locally?
- Create a dummy repository in github with a couple branches.
- Run server:  `rails s -p 3001`
- In another terminal run ngrok: `ngrok http 3001`
- Copy ngrok url to github configuration page (settings->webhooks)
`http://xxxxxxx.ngrok.io/api/v1/notifications_filter`
- Change CHANNEL in SlackNotificationService to your `@name` or `#some_test_channel`
- Create/edit pull request adding or removing labels. This will execute the webhook.

## ActiveAdmin page 
You can access the admin page at `http://localhost:3001/admin/users` and add users that you want to ignore 

## Deploy to Heroku
Install heroku cli https://devcenter.heroku.com/articles/heroku-cli#download-and-install
* Setup:
```
heroku login
enter credentials
heroku git:remote -a rootstrap-pull-request-to-slack
```

* Push:
```
git push heroku master
```

## Docs

#### Ngrok
Public URLs for exposing your local web server
https://ngrok.com/

#### Github Hooks
Info about github hooks and Pull request payload

https://developer.github.com/webhooks/configuring/
https://developer.github.com/v3/activity/events/types/#pullrequestevent

#### Slack methods
https://api.slack.com/methods

## Contributing
Bug reports (please use Issues) and pull requests are welcome on GitHub at https://github.com/rootstrap/pull_requests_to_slack/issues. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits
Github for Slack is maintained by [Rootstrap](http://www.rootstrap.com) with the help of our [contributors](https://github.com/rootstrap/pull_requests_to_slack/contributors).

[<img src="https://s3-us-west-1.amazonaws.com/rootstrap.com/img/rs.png" width="100"/>](http://www.rootstrap.com)
