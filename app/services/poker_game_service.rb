# frozen_string_literal: true

class PokerGameService < BaseService
  attr_reader :event, :params, :game, :stream_key

  def initialize(event)
    @event = event.with_indifferent_access
    @params = ActionController::Parameters.new(@event[:params])
    @game = Game.find(params.dig(:game, :id))
    @stream_key = "game_#{game.id}"
  end

  def run
    case event[:type]
    when 'user_join'
      handle_user_join_event
    when 'user_leave'
      handle_user_leave_event
    when 'update_vote'
      handle_update_vote_event
    when 'update_game'
      handle_update_game_event
    else
      raise 'Invalid type'
    end

    if errors.empty?
      data = { game: GameSerializer.new(@game).run }
      ActionCable.server.broadcast("game_#{@game.id}", data)
      true
    else
      Rails.logger.error { "PokerGameService #{errors.full_messages.join(', ')}" }
      false
    end
  end

  private

  def handle_user_join_event
    user = User.find(params.dig(:user, :id))
    @game.votes.find_or_create_by!(user: user)
  end

  def handle_user_leave_event
    user = User.find(params.dig(:user, :id))
    @game.votes.destroy_by(user: user)
  end

  def handle_update_vote_event
    errors.add(:base, 'invalid game status') unless game.voting?

    vote = Vote.find_by!(
      id: params.dig(:vote, :id), user_id: params.dig(:user, :id), game_id: game.id
    )
    vote.assign_attributes(vote_params)
    errors.copy!(vote.errors) unless vote.save
  end

  def handle_update_game_event
    game.assign_attributes(game_params)
    reset_vote_values = game.status_changed? && game.status == 'voting'

    if game.save
      game.votes.update_all(value: nil) if reset_vote_values
    else
      errors.copy!(game.errors) unless game.save
    end
  end

  def vote_params
    params.require(:vote).permit(:value)
  end

  def game_params
    params.require(:game).permit(:status)
  end
end
