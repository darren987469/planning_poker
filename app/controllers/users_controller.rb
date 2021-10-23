class UsersController < ApplicationController
  def new
    return redirect_to new_game_path if current_user

    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:current_user_id] = @user.id

      if session[:game_code] && (game = Game.find_by(code: session[:game_code]))
        game.votes.create(user: @user)
        redirect_to game_url(game.code)
      else
        redirect_to new_game_url
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
