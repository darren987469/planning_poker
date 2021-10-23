class PokerChannel < ApplicationCable::Channel
  def subscribed
    stream_from stream_key(params.dig(:game, :id))
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(event)
    service = PokerGameService.new(event)
    if service.run
      game = service.game
      data = { game: GameSerializer.new(game).run }
      ActionCable.server.broadcast(stream_key(game.id), data)
    else
      Rails.logger.info { "onReceive error #{service.errors.full_messages.join(',')}" }
    end
  end

  private

  def stream_key(game_id)
    "game_#{game_id}"
  end
end
