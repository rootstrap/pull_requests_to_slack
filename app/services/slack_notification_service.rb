class SlackNotificationService
  ACTION_METHODS = {
    'opened' => :filter_opened_action,
    'ready_for_review' => :filter_ready_for_review_action,
    'unlabeled' => :filter_unlabeled_action,
    'labeled' => :filter_on_hold_labeled_action,
    'closed' => :filter_closed_action,
  }.freeze
  EMOJI_HASH =  {
    'JavaScript' => ':javascript:',
    'TypeScript' => ':javascript:',
    'Ruby' => ':ruby:',
    'Java' => ':java:',
    'Kotlin' => ':kotlin:',
    'Swift' => ':swift:',
    'React' => ':react:',
    'React-Native' => ':react_native:',
    'Angular' => ':angular:',
    'Python' => ':python:',
    'HTML' => ':html5:'
  }.freeze

  ON_HOLD = 'ON HOLD'.freeze
  CHANNEL = '#code-review'.freeze

  attr_reader :action, :extra_params, :client

  def initialize(params)
    @action = params[:github_webhook][:action]
    @extra_params = params
    @client = Slack::Web::Client.new
  end

  def send_notification
    send(ACTION_METHODS[action]) if ACTION_METHODS.key? action
  end

  private

  def notify_pull_request
    username = extra_params[:pull_request][:user][:login]
    icon_url = extra_params[:pull_request][:user][:avatar_url]
    client.chat_postMessage(channel: CHANNEL, text: message, as_user: false, username: username, icon_url: icon_url )
  end

  def filter_unlabeled_action
    label_name = extra_params[:github_webhook][:label][:name]
    notify_pull_request if on_hold_label? label_name
  end

  def filter_on_hold_labeled_action
    label_name = extra_params[:github_webhook][:label][:name]
    pull_request_url = extra_params[:pull_request][:html_url]
    return unless on_hold_label?(label_name)

    matches = find_message pull_request_url
    delete_message matches
  end

  def filter_opened_action
    is_draft = extra_params[:pull_request][:draft]
    notify_pull_request unless on_hold_pr? || is_draft
  end

  def filter_ready_for_review_action
    notify_pull_request unless on_hold_pr?
  end

  def filter_closed_action
    is_merged = extra_params[:pull_request][:merged]
    filter_merged_action if is_merged
  end

  def filter_merged_action
    pull_request_url = extra_params[:pull_request][:html_url]
    matches = find_message pull_request_url
    add_merge_emoji matches
  end

  def add_merge_emoji(matches)
    matches.each do |match|
      timestamp = match[:ts]
      begin
        add_emoji :merged, timestamp
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}."
      end
    end
  end

  def find_message(text)
    client_find = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
    response = client_find.search_messages(channel: CHANNEL, query: "#{text} in:#{CHANNEL}")
    response.dig(:messages, :matches)
  end

  def delete_message(matches)
    matches.each do |match|
      timestamp = match[:ts]
      begin
        client.chat_delete(channel: CHANNEL, ts: timestamp) if timestamp
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}."
      end
    end
  end

  def on_hold_label?(label)
    label.downcase == ON_HOLD.downcase
  end

  def on_hold_pr?
    labels = extra_params[:pull_request][:labels]
    labels&.any? { |label| on_hold_label? label[:name] }
  end

  def message
    pull_request_url = extra_params[:pull_request][:html_url]
    language = extra_params[:repository][:language]
    repo_name = extra_params[:repository][:name].downcase
    slack_body = extract_slack_body extra_params[:pull_request][:body]
    "#{pull_request_url} #{slack_body} #{language_emoji(language, repo_name)}"
  end

  def extract_slack_body(body)
    body = body.gsub("\r\n",' ').split('\slack ')[1] || ''
    format_body body
  end

  # To show the notification @test it should be formatted like <@test>
  # https://api.slack.com/docs/message-formatting
  def format_body(body)
    body.gsub(/([@#][A-Za-z0-9_]+)/, "<\\1>")
  end

  def language_emoji(language, repo_name)
    if repo_name.include? 'react-native' or repo_name.include? 'reactnative'  or repo_name.ends_with? '-rn'
      language = 'React-Native'
    elsif repo_name.include? 'react'
      language = 'React'
    elsif repo_name.include? 'angular'
      language = 'Angular'
    end
    EMOJI_HASH.fetch language, "[#{language}]"
  end

  def add_emoji(emoji, timestamp)
    client.reactions_add(
      name: emoji,
      channel: CHANNEL,
      timestamp: timestamp,
      as_user: false)
  end
end
