# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string
#  first_name  :string           default("")
#  last_name   :string           default("")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  github_name :string
#  slack_name  :string
#  blacklisted :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_github_name  (github_name)
#

require 'rails_helper'

describe User do
  context 'when was created with regular login' do
    let!(:user) { create(:user) }
    let(:full_name) { user.full_name }

    it 'returns the correct name' do
      expect(full_name).to eq(user.github_name)
    end
  end
end
