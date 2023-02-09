module Api
  module V1
    class SessionsController < ApplicationController
    include SessionHelper

    def create
    user_info = JWT.decode(session_params[:access_token], nil, false).first
    user = User.find_by(id: user_info["user_id"])
    render json: { user: }, status: :ok if login(user)
    end

    def destroy
    reset_session
    cookies.delete(:user_id, max_age: 0)
    cookies.delete(:logged_in, max_age: 0)
    render status: :ok
    end

    private
    def session_params
    params.require(:session).permit(:access_token)
    end
    end
  end
end
