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

    let!(:user) do
      User.create(github_name: 'pepe', blacklisted: false)
    end

    context 'with valid params' do
      let(:params) do
        {
          github_webhook: { action: described_class::ACTION_METHODS.keys.sample },
          channel: '#code-review',
          pull_request: { user: { login: 'pepe' } }
        }
      end

      before do
        stub_request(:post, 'https://slack.com/api/conversations.list')
          .to_return(status: 200, body: '', headers: {})
      end

      it 'sends the message' do
        expect_any_instance_of(described_class).to receive(:send).and_return(nil)
        subject
      end

      context 'with a PR from a blacklisted user' do
        let!(:user) { User.create(github_name: 'pepe', blacklisted: true) }

        it 'does NOT send the message' do
          expect_any_instance_of(described_class).not_to receive(:send)
          subject
        end
      end
    end
  end
end
