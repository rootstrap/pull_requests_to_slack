class SlackNotificationService
  ACTION_METHODS = {
    'opened' => :filter_opened_action,
    'unlabeled' => :filter_unlabeled_action,
    'labeled' => :filter_on_hold_labeled_action
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
    pull_request_url = extra_params[:pull_request][:html_url]
    client.chat_postMessage(channel: CHANNEL, text: pull_request_url)
  end

  def filter_unlabeled_action
    label_name = extra_params[:github_webhook][:label][:name]
    notify_pull_request if on_hold? label_name
  end

  def filter_on_hold_labeled_action
    label_name = extra_params[:github_webhook][:label][:name]
    pull_request_url = extra_params[:pull_request][:html_url]
    return unless on_hold?(label_name)

    matches = find_message pull_request_url
    delete_message matches
  end

  def filter_opened_action
    labels = extra_params[:pull_request][:labels]
    notify_pull_request unless labels&.any? { |label| on_hold? label[:name] }
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

  def on_hold?(label)
    label.downcase == ON_HOLD.downcase
  end
end
