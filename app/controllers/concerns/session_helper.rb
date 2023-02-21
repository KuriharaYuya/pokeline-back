module SessionHelper
  extend ActiveSupport::Concern

  def login(user)
    if user.nil?
      render json: {}, status: :not_found
      false
    else
      session[:user_id] = user.id
      cookies["user_id"] = {
        value: user.id,
        max_age: 3600 * 24 * 7,
        secure: true,
        same_site: Rails.env.production? ? :none : :lax,
      }
      cookies["logged_in"] = {
        value: true,
        max_age: 3600 * 24 * 7,
        secure: true,
        same_site: Rails.env.production? ? :none : :lax,
      }
      true
    end
  end

  def current_user
    user_id = Rails.env.production? ? session[:user_id] : cookies[:user_id]
    @current_user ||= User.find_by(id: user_id)
  end

  def authenticate_user
    return unless Rails.env.production?

    if session[:user_id] != cookies[:user_id]
      render json: { message: "anauthorized" }, status: :unauthorized
    end
  end
end
