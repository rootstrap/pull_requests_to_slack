FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    username { Faker::Internet.unique.user_name }
  end
end
