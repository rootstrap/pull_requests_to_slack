# Rootstrap Github for Slack

## Description
TO BE COMPLETED

## How to use

1. Clone this repo
2. Install PostgreSQL in case you don't have it
3. Create your `database.yml` and `application.yml` file
4. `bundle install`
5. Generate a secret key with `rake secret` and paste this value into the `application.yml`.
6. `rake db:create`
7. `rake db:migrate`
8. `run rake db:seed`  //this will create an admin with admin@example.com:password
9. `sudo npm install -g ngrok` Install Ngrok
10. `rspec` and make sure all tests pass
11. `rails s`
12. You can now try your REST services!

## Backlog
https://trello.com/invite/b/r6hhrp56/7251cf848a9a95e2362432ba986b5185/rs-github-for-slack

## Docs

### Ngrok
Public URLs for exposing your local web server
https://ngrok.com/

### Github Hooks
Info about github hooks and Pull request payload

https://developer.github.com/webhooks/configuring/
https://developer.github.com/v3/activity/events/types/#pullrequestevent

### Slack methods 
https://api.slack.com/methods

## Dummy repository for testing
Create dummy repository, with a couple branches.

Create webhook in repository: Go to settings and add ngrok url (http://xxxxxxxx.ngrok.io/api/v1/notifications_filter)

Create a new PR from branch to branch to execute  the webhook.

## To test
- Run server:  `rails s -p 3001`
- In another terminal run ngrok: `ngrok http 3001`
- Copy ngrok url to github configuration page (settings->hooks) 
`http://0a2a8253.ngrok.io/api/v1/notifications_filter`
- Change CHANNEL in SlackNotificationService to your @name or #some_test_channel
- Create/edit pull request adding removing labels

## Deploy to Heroku
```
git remote -v 
heroku git:remote -a rootstrap-github-for-slack
enter credentials
git push heroku master
```

[<img src="https://s3-us-west-1.amazonaws.com/rootstrap.com/img/rs.png" width="100"/>](http://www.rootstrap.com)
