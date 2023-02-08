module SessionHelper
  extend ActiveSupport::Concern

  def login(user)
    if user.nil?
      render json: {}, status: :not_found
      return
    end

    session[:user_id] = user.id
    cookies["user_id"] = {
      value: user.id,
      max_age: 3600 * 24 * 7,
      httponly: true,
      secure: true,
    }
  end
end
