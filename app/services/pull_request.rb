class PullRequest
  ON_HOLD = 'ON HOLD'.freeze
  attr_reader :username, :avatar_url, :webhook_label, :url

  def initialize(params)
    @username = params.dig(:pull_request, :user, :login)
    @avatar_url = params.dig(:pull_request, :user, :avatar_url)
    @webhook_label = params.dig(:github_webhook, :label, :name)
    @url = params.dig(:pull_request, :html_url)
    @params = params
  end

  def on_hold_webhook?
    on_hold_label? @webhook_label
  end
  
  def on_hold?
    @params.dig(:pull_request, :labels)&.any? { |label| on_hold_label? label[:name] } || false
  end
  
  def is_draft?
    @params.dig(:pull_request, :draft) == true
  end
  
  def is_merged?
    @params.dig(:pull_request, :merged) == true
  end
  
  def on_hold_label?(label)
    label.downcase == ON_HOLD.downcase
  end

end
