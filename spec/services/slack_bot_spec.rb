require 'rails_helper'

describe 'SlackBot' do
  let(:subject) { SlackBot.new({ channel: 'demo_channel' }) }
  describe '#language_emoji' do
    context 'when the repo includes React' do
      it 'returns the correct emoji' do
        expect(subject.language_emoji('javascript', 'this-is-react-repo')).to eq ':react:'
      end
    end
    context 'when there is no emoji in the hash' do
      it 'returns the default emoji (downcase language)' do
        expect(subject.language_emoji('Exotic', 'repo_name')).to eq ':exotic:'
      end
    end
  end
end
