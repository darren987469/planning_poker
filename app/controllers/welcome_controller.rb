class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to new_game_url
    else
      redirect_to new_user_url
    end
  end
end
