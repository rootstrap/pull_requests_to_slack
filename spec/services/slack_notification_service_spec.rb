require 'rails_helper'

describe SlackNotificationService do
  describe 'initialization' do
    subject { described_class.new({}) }

    it 'raise an error if no action is set in params' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end

  describe '#send_notification' do
    subject { described_class.new(params).send_notification }

    let(:username) { Faker::Internet.username }
    let!(:user) do
      User.create(github_name: username, blacklisted: false)
    end

    context 'with valid params' do
      let(:random_action) { described_class::ACTION_METHODS.keys.sample }
      let(:channel_name) { described_class::DEFAULT_CHANNEL }
      let(:some_language) { 'Node' }
      let(:params) do
        {
          github_webhook: {
            action: random_action,
            label: { name: Faker::Internet.slug(words: '_') }
          },
          channel: channel_name,
          pull_request: {
            user: { login: username },
            body: Faker::Lorem.sentence
          },
          repository: {
            name: Faker::Internet.slug,
            language: some_language
          }
        }
      end

      before do
        stub_request(:post, 'https://slack.com/api/conversations.list')
          .to_return(status: 200, body: '', headers: {})

        # stub_request(:post, 'https://slack.com/api/conversations.info')
        #   .with(body: { 'channel': 'node-code-review' })
        #   .to_return(status: 200, body: '', headers: {})

        stub_request(:post, 'https://slack.com/api/chat.postMessage')
          .with(
            body: {
              'channel': channel_name,
              'text': '  :nodejs:',
              'username': username
            }
          ).to_return(status: 200, body: '', headers: {})
      end

      it 'sends the message' do
        expect_any_instance_of(described_class)
          .to receive(:send)
          .with(described_class::ACTION_METHODS[random_action])
          .and_call_original
        subject
      end

      context 'with a PR from a blacklisted user' do
        let!(:user) { User.create(github_name: username, blacklisted: true) }

        it 'does NOT send the message' do
          expect_any_instance_of(described_class).not_to receive(:send)
          subject
        end
      end
    end
  end
end
