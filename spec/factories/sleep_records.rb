FactoryBot.define do
  factory :sleep_record do
    user
    clock_in { Faker::Time.between(from: 1.day.ago, to: Time.current) }
    duration_seconds { 0 }
  end
end
