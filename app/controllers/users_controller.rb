class UsersController < ApplicationController
  before_action :redirect_if_current_user, only:

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:current_user_id] = @user.id

      if session[:game_code]
        redirect_to game_url(session[:game_code])
      else
        redirect_to new_game_url
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_current_user
    redirect_to new_game_path if current_user
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
