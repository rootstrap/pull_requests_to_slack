require 'rails_helper'

describe 'GET api/v1/notifications_filter', type: :request do
  let(:pull_request_link) { 'https://github.com/rootstrap/example-project/pull/1' }

  context 'when there is a open pull request notification' do
    let(:params) do
      {
        action: 'opened',
        pull_request: {
          html_url: pull_request_link
        }
      }
    end

    it 'sends a slack notification to a given channel with the PR notification' do
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
        .with(channel: '#code-review', text: pull_request_link)

      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end

  context 'when there is a closed pull request notification' do
    let(:params) do
      {
        action: 'merged',
        pull_request: {
          html_url: pull_request_link
        }
      }
    end

    it 'sends a slack notification to a given channel with the PR notification' do
      expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)
        .with(channel: '#code-review', text: pull_request_link)

      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end
end
