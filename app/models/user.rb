# frozen_string_literal: true

class User < ApplicationRecord
  has_many :votes
  has_many :games, through: :votes

  validates :name, presence: true
end
