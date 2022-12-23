class SlackNotificationService
  ACTION_METHODS = { 'opened' => :filter_opened_action,
                     'ready_for_review' => :filter_ready_for_review_action,
                     'unlabeled' => :filter_unlabeled_action,
                     'labeled' => :filter_on_hold_labeled_action,
                     'closed' => :filter_closed_action }.freeze

  DEFAULT_CHANNEL = '#code-review'.freeze

  LANGUAGES = {
    'Angular': 'angular',
    'C': 'c',
    'C#': 'csharp',
    'C++': 'cplusplus',
    'CoffeeScript': 'coffescript',
    'CSS': 'css',
    'Dart': 'dart',
    'Dockerfile': 'dockerfile',
    'EJS': 'ejs',
    'Elixir': 'elixir',
    'Flutter': 'flutter',
    'Gherkin': 'gherkin',
    'Go': 'go',
    'HCL': 'hcl',
    'HTML': 'html',
    'Java': 'java',
    'JavaScript': 'javascript',
    'Jinja': 'jinja',
    'Jupyter Notebook': 'jupyter-notebook',
    'Kotlin': 'kotlin',
    'Makefile': 'makefile',
    'Objective-C': 'objectivec',
    'PHP': 'php',
    'Python': 'python',
    'R': 'r',
    'React': 'react',
    'React-Native': 'react-native',
    'Ruby': 'ruby',
    'Rust': 'rust',
    'SCSS': 'scss',
    'Shell': 'shell',
    'Solidity': 'solidity',
    'Swift': 'swift',
    'TypeScript': 'typescript',
    'Vue': 'vue'
  }.freeze

  attr_reader :action, :extra_params, :slack_bot, :pr

  def initialize(params)
    @action = params[:github_webhook][:action]
    @extra_params = params
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
    lang = LANGUAGES[params.dig("repository", "language")&.to_sym]
    repository_info = params.dig("repository")

    if lang
      return js_channels(repository_info) if lang == 'javascript'

      "##{lang}-reviewers"
    else
      DEFAULT_CHANNEL
    end
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

  def js_channels(pr)
    repo_name = pr['name'].downcase
    language = 'javascript'

    if (repo_name.include? 'react') && (repo_name.include? 'native')
      language = LANGUAGES[:'React-Native']
    elsif repo_name.include? 'react'
      language = LANGUAGES[:React]
    elsif repo_name.include? 'angular'
      language = LANGUAGES[:Angular]
    end

    return "##{language}-reviewers"
  end
end
