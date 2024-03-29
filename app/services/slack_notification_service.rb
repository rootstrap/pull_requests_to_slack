class SlackNotificationService
  ACTION_METHODS = { 'opened' => :filter_opened_action,
                     'ready_for_review' => :filter_ready_for_review_action,
                     'unlabeled' => :filter_unlabeled_action,
                     'labeled' => :filter_on_hold_labeled_action,
                     'closed' => :filter_closed_action }.freeze

  DEFAULT_CHANNEL = '#code-review'.freeze

  LANGUAGES = {
    'Ruby': 'ruby',
    'Node': 'node',
    'Python': 'python',
    'React': 'react',
    'React-Native': 'react-native',
    'Dart': 'flutter',
    'Objective-C': 'ios',
    'Kotlin': 'android',
    'Swift': 'ios',
    'TypeScript': 'typescript',
    'JavaScript': 'javascript'
  }.freeze

  attr_reader :action, :extra_params, :slack_bot, :pr

  def initialize(params)
    @action = params.dig(:github_webhook, :action)
    if @action.blank?
      Rails.logger.warn("Warning! No action found on params: [#{params}]")
    end

    @extra_params = params || {}
    @slack_bot = SlackBot.new(channel: channel(params))
    @pr = PullRequest.new(params)
  end

  def send_notification
    return if pr.blacklisted?

    send(ACTION_METHODS[action]) if ACTION_METHODS.key? action
  end

  private

  def notify_pull_request
    message = slack_bot.message(pr)
    slack_bot.notify(message, pr.username, pr.avatar_url)
  end

  def filter_unlabeled_action
    notify_pull_request if pr.on_hold_webhook?
  end

  def filter_on_hold_labeled_action
    return unless pr.on_hold_webhook?

    matches = slack_bot.find_message pr.url
    slack_bot.delete_message matches
  end

  def channel(params)
    lang = LANGUAGES[params.dig(:repository, :language)&.to_sym]
    repository_info = params[:repository]

    channel = build_channel(lang, repository_info)
    channel_name = "##{channel}"

    if channel.present? && search_channel(channel_name)
      channel_name
    else
      DEFAULT_CHANNEL
    end
  end

  def search_channel(channel)
    Slack::Web::Client.new.conversations_info(channel: channel)
  rescue StandardError => e
    Rails.logger.error("Error #{e.inspect} for channel #{channel}")
    nil
  end

  def build_channel(lang, repository_info)
    return 'devops-code-review' if devops_pr?(repository_info)

    return build_lang_channel(lang, repository_info) if lang
  end

  def build_lang_channel(lang, repository_info)
    return js_channels(repository_info, lang) if %w[javascript typescript].include?(lang)

    "#{lang}-code-review"
  end

  def devops_pr?(repository_info)
    return false unless repository_info

    repo_name = repository_info[:name]
    repo_topics = repository_info[:topics]

    (repo_name&.include? 'devops') ||
      (repo_name&.include? 'infra') ||
      (repo_topics&.include? 'terraform')
  end

  def filter_opened_action
    notify_pull_request unless pr.on_hold? || pr.draft?
  end

  def filter_ready_for_review_action
    notify_pull_request unless pr.on_hold?
  end

  def filter_closed_action
    filter_merged_action if pr.merged?
  end

  def filter_merged_action
    matches = slack_bot.find_message pr.url
    slack_bot.add_merge_emoji matches
  end

  def js_channels(pull_request, _lang)
    return unless pull_request[:name]

    repo_name = pull_request[:name].downcase
    topics = pull_request[:topics].present? ? pull_request[:topics] : []

    js_repo_name(repo_name, topics)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def js_repo_name(repo_name, topics)
    if ((repo_name.include? 'react') &&
      (repo_name.include? 'native')) ||
       (topics.include? 'react-native')
      "#{LANGUAGES[:'React-Native']}-code-review"
    elsif (repo_name.include? 'react') || (topics.include? 'react')
      "#{LANGUAGES[:React]}-code-review"
    elsif (repo_name.include? 'node') || (topics.include? 'node')
      "#{LANGUAGES[:Node]}-code-review"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
