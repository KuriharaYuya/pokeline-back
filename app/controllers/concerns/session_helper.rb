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
        domain: "poke-line.vercel.app",
        secure: secure_cookies?,
      }
      cookies["logged_in"] = {
        value: true,
        max_age: 3600 * 24 * 7,
        domain: "poke-line.vercel.app",
        secure: secure_cookies?,
      }
      true
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user
    if session[:user_id] != cookies[:user_id]
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
  end

  private

  def secure_cookies?
    Rails.env.production?
  end
end
