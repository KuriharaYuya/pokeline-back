module Api
  module V1
    class SessionsController < ApplicationController

      def create
        user_info = JWT.decode(session_params[:access_token], nil, false).first
        user = User.find_by(uid: user_info["user_id"])
        if user.nil?
            render json: {}, status: :not_found
            return
        end

        session[:user_id] = user.id
        cookies["user_id"] = {
          value: user.uid,
          max_age: 3600 * 24 * 7,
          httponly: true,
          secure: true,
        }
        render json: { user: }, status: :ok
      end

      def destroy
        reset_session
        cookies.delete(:user_id, max_age: 0)
        render status: :ok
      end

      private
      def session_params
        params.require(:session).permit(:access_token)
      end
    end
  end
end
