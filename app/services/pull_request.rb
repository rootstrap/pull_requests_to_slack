class PullRequest
  ON_HOLD = 'ON HOLD'.freeze
  attr_reader :info, :username, :avatar_url, :webhook_label, 
              :url, :body, :language, :repo_name

  def initialize(params)
    @info = params.dig(:pull_request)
    @username = @info.dig(:user, :login)
    @avatar_url = @info.dig(:user, :avatar_url)
    @webhook_label = params.dig(:github_webhook, :label, :name)
    @url = @info[:html_url]
    @body = @info[:body]
    @language = params.dig(:repository, :language)
    @repo_name = params.dig(:repository, :name)&.downcase
  end

  def on_hold_webhook?
    on_hold_label? @webhook_label
  end

  def on_hold?
    @info[:labels]&.any? { |label| on_hold_label? label[:name] } || false
  end

  def is_draft?
    @info[:draft] == true
  end

  def is_merged?
    @info[:merged] == true
  end

  def on_hold_label?(label)
    label.downcase == ON_HOLD.downcase
  end

end
