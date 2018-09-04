require 'rails_helper'

describe 'GET api/v1/notifications_filter', type: :request do
  let(:channel) {'#code-review'}
  let(:pull_request_link) { 'https://github.com/rootstrap/example-project/pull/1' }
  let(:message) { "#{pull_request_link} <@user> Tiny PR :javascript:" }
  let(:pull_request) do
    {
      html_url: pull_request_link,
      title: 'Update the README with new information',
      ts: '1234',
      body: 'This is the body \slack @user Tiny PR',
      user: {
        login: 'user',
        avatar_url: 'image.png'
      }
    }
  end

  context 'when there is an open pull request notification' do
    let(:params) do
      {
        action: 'opened',
        pull_request: pull_request,
        repository: {
          language: 'JavaScript',
          name: 'example'
        }
      }
    end

    it 'sends a slack notification to a given channel with the PR notification' do
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
        .with(channel: channel, text: message, as_user: false, username: 'user', icon_url: 'image.png')

      post api_v1_notifications_filter_path, params: params, as: :json
    end

    context 'repo name includes a language' do
      before do
        params[:repository][:name] = 'example-React-Native'
      end
      it 'sends a slack notification to a given channel with the PR notification and specific language emoji' do
        expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
          .with(channel: channel, text: "#{pull_request_link} <@user> Tiny PR :react_native:", as_user: false, username: 'user', icon_url: 'image.png')

        post api_v1_notifications_filter_path, params: params, as: :json
      end
    end
    
    context 'pr body does not include a \slack message' do
      before do
        pull_request[:body] = "This is a simple body"
      end
      it 'sends a slack notification to a given channel with the PR notification and specific language emoji' do
        expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
          .with(channel: channel, text: "#{pull_request_link}  :javascript:", as_user: false, username: 'user', icon_url: 'image.png')

        post api_v1_notifications_filter_path, params: params, as: :json
      end
    end
  end

  context 'when there is a closed pull request notification' do
    let(:params) do
      {
        action: 'merged',
        pull_request: pull_request
      }
    end

    it 'does NOT send a notification' do
      expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)
        .with(channel: channel, text: message)

      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end

  context 'when the "on hold" label is removed' do
    let(:params) do
      {
        action: 'unlabeled',
        pull_request: pull_request,
        label: { name: 'ON HOLD' },
        repository: {
          language: 'JavaScript',
          name: 'example'
        }
      }
    end

    it 'sends a slack notification to a given channel with the PR notification and language emoji' do
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
        .with(channel: channel, text: message, as_user: false, username: 'user', icon_url: 'image.png')

      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end

  context 'when there is an open pull request notification with the "ON HOLD" label' do
    let(:params) do
      {
        action: 'opened',
        pull_request: {
          html_url: pull_request_link,
          title: 'Update the README with new information',
          labels: [
            { name: 'ON HOLD' },
            { name: 'bug' }
          ]
        },
        repository: {
          language: 'JavaScript'
        }
      }
    end

    it 'does NOT send a notification' do
      expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)
        .with(channel: channel, text: pull_request_link)

      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end

  context 'when the "ON HOLD" label is added' do
    let(:params) do
      {
        action: 'labeled',
        pull_request: pull_request,
        label: { name: 'ON HOLD' }
      }
    end

    it 'deletes the messages that contains the PR link' do
      expect_any_instance_of(Slack::Web::Client).to receive(:search_messages)
        .and_return(messages: { matches: [{ ts: '1234' }] })
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_delete)
        .with(channel: channel, ts: '1234')
      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end
end
