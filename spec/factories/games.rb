# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    name { 'poker game' }
    code { 'code' }
    status { 'not_started' }
  end
end
