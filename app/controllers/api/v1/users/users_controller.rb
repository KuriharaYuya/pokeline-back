module Api
  module V1
    module Users
      class UsersController < ApplicationController
        require "jwt"

        def create
          user_info = JWT.decode(user_params[:access_token], nil, false).first
          name, email, user_id, picture = user_info.values_at("name", "email", "user_id", "picture")
          user = User.new(name:, email:, id: user_id, picture:)
          render json: { user: }, status: :ok if user.save
        end

        private

        def user_params
          params.require(:user).permit(:access_token)
        end
      end
    end
  end
end
