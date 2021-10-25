# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :game
  belongs_to :user
end
