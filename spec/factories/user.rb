FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    github_name { Faker::Internet.unique.user_name }
    blacklisted { false }
  end
end
