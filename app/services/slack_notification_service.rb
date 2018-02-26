class SlackNotificationService
  ACTION_METHODS = {
    'opened' => :notify_open_pull_request
  }

  attr_reader :action, :extra_params

  def initialize(params)
    @action = params[:github_webhook][:action]
    @extra_params = params
  end

  def send_notification
    send(ACTION_METHODS[action])
  end

  private

  def notify_open_pull_request
    pull_request_url = extra_params[:pull_request][:html_url]
    client = Slack::Web::Client.new
    client.chat_postMessage(channel: '#code-review', text: pull_request_url)
  end
end
