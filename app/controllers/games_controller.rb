class GamesController < ApplicationController
  before_action :redirect_unless_current_suer, only: %i[new create]
  before_action :set_game, only: %i[edit update destroy]
  before_action :set_game_by_code, only: %i[show]

  # GET /games
  def index
    @games = Game.all
  end

  # GET /games/:code
  def show
    session[:game_code] = @game.code
    redirect_to new_user_url unless current_user

    @user_data = current_user.to_json
    @game_data = GameSerializer.new(@game).run.to_json
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # POST /games
  def create
    @game = Game.new(game_params)

    if @game.save
      session[:game_code] = @game.code
      redirect_to game_url(@game.code), notice: "Game was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_unless_current_suer
    redirect_to new_user_url unless current_user
  end

  def set_game
    @game = Game.find(params[:id])
  end

  def set_game_by_code
    @game = Game.find_by!(code: params[:code])
  end

  def game_params
    params.require(:game).permit(:name, :code)
  end
end
