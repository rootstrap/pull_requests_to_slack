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

class User < ApplicationRecord
  def full_name
    return github_name unless first_name.present?
    "#{first_name} #{last_name}"
  end
end
