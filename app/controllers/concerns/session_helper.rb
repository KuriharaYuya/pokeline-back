module SessionHelper
  extend ActiveSupport::Concern

  def login(user)
    if user.nil?
      render json: {}, status: :not_found
      return false
    else
      session[:user_id] = user.id
      cookies["user_id"] = {
        value: user.id,
        max_age: 3600 * 24 * 7,
        secure: true,
      }
      cookies["logged_in"] = {
        value: true,
        max_age: 3600 * 24 * 7,
        secure: true,
      }
      return true
    end
  end
end
