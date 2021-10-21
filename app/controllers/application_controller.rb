class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound do
    render file: "#{Rails.root}/public/404.html",  layout: false, status: :not_found
  end

  if Rails.env.production?
    rescue_from StandardError do
      render file: "#{Rails.root}/public/500.html",  layout: false, status: :internal_server_error
    end
  end

  def current_user
    return @current_user if @current_user_loaded

    @current_user = if session[:current_user_id]
                      User.find_by(id: session[:current_user_id])
                    end
    @current_user_loaded = true

    @current_user
  end
end
