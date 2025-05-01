FactoryBot.define do
  factory :user_follower do
    association :user, factory: :user
    association :follower, factory: :user
  end
end 
