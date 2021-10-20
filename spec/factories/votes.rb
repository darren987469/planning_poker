FactoryBot.define do
  factory :vote do
    game
    user
    value { nil }
  end
end
