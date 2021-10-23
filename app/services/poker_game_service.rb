class PokerGameService < BaseService
  attr_reader :event, :params, :game

  def initialize(event)
    @event = event.with_indifferent_access
    @params = ActionController::Parameters.new(@event[:params])
  end

  def run
    case event[:type]
    when 'update_vote'
      handle_update_vote_event
    when 'update_game'
      handle_update_game_event
    else
      raise 'Invalid type'
    end

    if errors.empty?
      true
    else
      false
    end
  end

  private

  def handle_update_vote_event
    @game = Game.find(params.dig(:game, :id))
    errors.add(:base, 'invalid game status') unless game.voting?

    vote = Vote.find_by!(
      id: params.dig(:vote, :id), user_id: params.dig(:user, :id), game_id: game.id
    )
    vote.assign_attributes(vote_params)
    errors.copy!(vote.errors) unless vote.save
  end

  def handle_update_game_event
    @game = Game.find(params.dig(:game, :id))
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
