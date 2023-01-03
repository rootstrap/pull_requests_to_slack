require 'rails_helper'

describe 'GET api/v1/notifications_filter', type: :request do
  let(:channel) { '#code-review' }
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

  let(:recovered_channel) do
    Slack::Messages::Message.new(channel: channel)
  end

  before { mock_channel_response(nil) }

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
      expect_notification
    end

    context 'when repository is has angular code' do
      it 'sends message to correct channel' do
        params[:repository][:name] = 'example-Angular-repository'
        expect_notification(text: "#{pull_request_link} <@user> Tiny PR :angular:")
      end
    end

    context 'repo name includes a technology' do
      before { mock_channel_response(channel) }

      context 'technology is react native' do
        let(:channel) { '#react-native-code-review' }

        it 'sends a slack notification with the PR link and language emoji' do
          params[:repository][:name] = 'example-React-Native'
          expect_notification(text: "#{pull_request_link} <@user> Tiny PR :react_native:")
        end
      end

      context 'technology is node' do
        let(:channel) { '#node-code-review' }

        it 'sends a slack notification with the PR link and language emoji' do
          params[:repository][:name] = 'example-Node-repo'
          expect_notification(text: "#{pull_request_link} <@user> Tiny PR :nodejs:")
        end
      end
    end

    context 'with a language not supported' do
      let(:channel) { '#code-review' }

      it 'sends a slack notification with the PR link to #code-reviewers channel' do
        params[:repository][:language] = 'gherkin'
        expect_notification(text: "#{pull_request_link} <@user> Tiny PR :gherkin:")
      end
    end

    context 'with a language with no channel created' do
      let(:channel) { '#code-review' }

      it 'sends a slack notification with the PR link to #code-reviewers channel' do
        params[:repository][:language] = 'Flutter'
        expect_notification(text: "#{pull_request_link} <@user> Tiny PR :flutter:")
      end
    end

    context 'pr body does not include a \slack message' do
      it 'sends a slack notification with the PR link and language emoji' do
        pull_request[:body] = 'This is a simple body'
        expect_notification(text: "#{pull_request_link}  :javascript:")
      end
    end

    context 'when the user is blacklisted' do
      let!(:user) { create(:user, github_name: 'blacklisted_user', blacklisted: true) }
      it 'does not sends a slack notification with the PR link' do
        pull_request[:user][:login] = 'blacklisted_user'
        expect_not_notification
      end
    end
  end

  context 'when there is a closed pull request notification' do
    let(:params) do
      {
        action: 'closed',
        pull_request: pull_request
      }
    end

    it 'does NOT send a notification' do
      expect_not_notification
    end
  end

  context 'when there is a merged pull request notification' do
    let(:params) do
      {
        action: 'closed',
        pull_request: pull_request.merge('merged' => true)
      }
    end

    it ' adds the merged reaction' do
      expect_any_instance_of(Slack::Web::Client).to receive(:search_messages)
        .and_return(messages: { matches: [{ ts: '1234' }] })
      expect_any_instance_of(Slack::Web::Client).to receive(:reactions_add)
        .with(name: :merged, channel: channel, timestamp: '1234', as_user: false)

      post api_v1_notifications_filter_path, params: params, as: :json
    end
  end

  context 'when there is an draft request notification' do
    let(:params) do
      {
        action: 'opened',
        pull_request: pull_request.merge('draft' => true),
        repository: {
          language: 'JavaScript',
          name: 'example'
        }
      }
    end

    it 'does not sends a slack notification to a given channel with the PR notification' do
      expect_not_notification
    end
  end

  context 'when there is an ready_for_review request notification' do
    let(:params) do
      {
        action: 'ready_for_review',
        pull_request: pull_request,
        repository: {
          language: 'JavaScript',
          name: 'example'
        }
      }
    end

    it 'sends a slack notification to a given channel with the PR notification' do
      expect_notification
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

    it 'sends a slack notification with the PR link and language emoji' do
      expect_notification
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
      expect_not_notification
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

def expect_notification(text: message)
  expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
    .with(channel: channel, text: text, username: 'user', icon_url: 'image.png')

  post api_v1_notifications_filter_path, params: params, as: :json
end

def expect_not_notification
  expect_any_instance_of(Slack::Web::Client).to_not receive(:chat_postMessage)
  post api_v1_notifications_filter_path, params: params, as: :json
end

def mock_channel_response(return_value)
  allow_any_instance_of(SlackNotificationService).to receive(:search_channel)
  .and_return(return_value)
end

