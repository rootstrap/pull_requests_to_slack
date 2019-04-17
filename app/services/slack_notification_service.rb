class SlackNotificationService
  ACTION_METHODS = {
    'opened' => :filter_opened_action,
    'ready_for_review' => :filter_ready_for_review_action,
    'unlabeled' => :filter_unlabeled_action,
    'labeled' => :filter_on_hold_labeled_action,
    'closed' => :filter_closed_action,
  }.freeze

  CHANNEL = '#code-review'.freeze

  attr_reader :action, :extra_params, :slack_bot, :pr

  def initialize(params)
    @action = params[:github_webhook][:action]
    @extra_params = params
    @slack_bot = SlackBot.new(channel: CHANNEL)
    @pr = PullRequest.new(params)
  end

  def send_notification
    send(ACTION_METHODS[action]) if ACTION_METHODS.key? action
  end

  private

  def notify_pull_request
    message = @slack_bot.message(@pr)
    @slack_bot.notify(message, @pr.username, @pr.avatar_url)
  end

  def filter_unlabeled_action
    notify_pull_request if @pr.on_hold_webhook?
  end

  def filter_on_hold_labeled_action
    return unless @pr.on_hold_webhook?
    matches = @slack_bot.find_message @pr.url
    @slack_bot.delete_message matches
  end

  def filter_opened_action
    notify_pull_request unless @pr.on_hold? || @pr.is_draft?
  end

  def filter_ready_for_review_action
    notify_pull_request unless @pr.on_hold?
  end

  def filter_closed_action
    filter_merged_action if @pr.is_merged?
  end

  def filter_merged_action
    matches = @slack_bot.find_message @pr.url
    @slack_bot.add_merge_emoji matches
  end

end
