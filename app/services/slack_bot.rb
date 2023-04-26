class SlackBot
  ON_HOLD = 'ON HOLD'.freeze

  EMOJI_HASH = {  'JavaScript' => ':javascript:',
                  'TypeScript' => ':ts:',
                  'Ruby' => ':ruby:',
                  'Java' => ':java:',
                  'Kotlin' => ':kotlin:',
                  'Swift' => ':swift:',
                  'React' => ':react:',
                  'React-Native' => ':react_native:',
                  'Angular' => ':angular:',
                  'Vue' => ':vue:',
                  'Node' => ':nodejs:',
                  'Python' => ':python:',
                  'HTML' => ':html5:',
                  'Elixir' => ':elixir:',
                  'R' => ':r-lang:',
                  'PHP' => ':php:' }.freeze

  attr_reader :channel

  def initialize(params)
    @client = Slack::Web::Client.new
    @channel = params[:channel]
  end

  def notify(message, username, avatar_url)
    @client.chat_postMessage(channel: @channel, text: message,
                            username: username, icon_url: avatar_url)
  end

  def add_merge_emoji(matches)
    matches.each do |match|
      timestamp = match[:ts]
      begin
        add_emoji :merged, timestamp
      rescue StandardError => e
        puts "An error of type #{e.class} happened, message is #{e.message}."
      end
    end
  end

  def add_emoji(emoji, timestamp)
    @client.reactions_add(name: emoji,
                         channel: @channel,
                         timestamp: timestamp,
                         as_user: false)
  end

  def find_message(text)
    client_find = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
    response = client_find.search_messages(channel: @channel, query: "#{text} in:#{@channel}")
    response.dig(:messages, :matches)
  end

  def delete_message(matches)
    matches.each do |match|
      timestamp = match[:ts]
      begin
        @client.chat_delete(channel: @channel, ts: timestamp) if timestamp
      rescue StandardError => e
        puts "An error of type #{e.class} happened, message is #{e.message}."
      end
    end
  end

  def message(pull_req)
    slack_body = extract_slack_body(pull_req.body)
    "#{pull_req.url} #{slack_body} #{language_emoji(pull_req.language, pull_req.repo_name)}"
  end

  def extract_slack_body(body)
    body_gsub = body&.gsub("\r\n", ' ')&.split('\slack ')
    body = body_gsub[1].present? ? body_gsub[1] : ''
    format_body body
  end

  # To show the notification @test it should be formatted like <@test>
  # https://api.slack.com/docs/message-formatting
  def format_body(body)
    body.gsub(/([@#][A-Za-z0-9_]+)/, '<\\1>')
  end

  def language_emoji(language, repo_name)
    if repo_name =~ /reactnative|react-native|-rn$/
      language = 'React-Native'
    elsif repo_name.include? 'react'
      language = 'React'
    elsif repo_name.include? 'angular'
      language = 'Angular'
    elsif repo_name.include? 'node'
      language = 'Node'
    end

    EMOJI_HASH.fetch language, ":#{language&.downcase}:"
  end
end
