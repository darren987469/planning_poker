# frozen_string_literal: true

class GameSerializer
  def initialize(game)
    @game = game
  end

  def run
    @game.as_json(include: { votes: { include: :user } })
  end
end
