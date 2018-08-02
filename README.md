# Rootstrap Github for Slack

## Description
Send Github pull request notifications to Slack.

## Initial project setup

1. Clone this repo
2. Install PostgreSQL in case you don't have it
3. Create your `database.yml` and `application.yml` files. There are sample files in `/config`
4. `bundle install`
5. Generate a secret key with `rake secret` and paste this value into the `application.yml`.
6. Fill the `SLACK_API_TOKEN` and `SLACK_BOT_TOKEN` in `application.yml`. 
To get the credentials: log in to https://api.slack.com/apps, select your application and then click OAuth Tokens & Redirect URLs. `SLACK_API_TOKEN` is the `OAuth Access Token` and `SLACK_BOT_TOKEN` is `Bot User OAuth Access Token`
6. `rake db:create`
7. `rake db:migrate`
8. `rake db:seed`  # this will create an admin with admin@example.com:password
9. `npm install -g ngrok` Install Ngrok
10. `rspec` and make sure all tests pass
11. `rails s`
12. You are ready!

## How to test the webhook locally? 
- Create a dummy repository in github with a couple branches.
- Run server:  `rails s -p 3001`
- In another terminal run ngrok: `ngrok http 3001`
- Copy ngrok url to github configuration page (settings->hooks)
`http://xxxxxxx.ngrok.io/api/v1/notifications_filter`
- Change CHANNEL in SlackNotificationService to your `@name` or `#some_test_channel`
- Create/edit pull request adding or removing labels. This will execute the webhook.

## Deploy to Heroku
Install heroku cli https://devcenter.heroku.com/articles/heroku-cli#download-and-install

```
heroku login
enter credentials
heroku git:remote -a rootstrap-github-for-slack
git push heroku master
```

## Docs and Backlog

#### Backlog
[Acess the Trello board](https://trello.com/invite/b/r6hhrp56/7251cf848a9a95e2362432ba986b5185/rs-github-for-slack)

#### Ngrok
Public URLs for exposing your local web server
https://ngrok.com/

#### Github Hooks
Info about github hooks and Pull request payload

https://developer.github.com/webhooks/configuring/
https://developer.github.com/v3/activity/events/types/#pullrequestevent

#### Slack methods 
https://api.slack.com/methods

[<img src="https://s3-us-west-1.amazonaws.com/rootstrap.com/img/rs.png" width="100"/>](http://www.rootstrap.com)
