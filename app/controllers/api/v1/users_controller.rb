module Api
  module V1
    class UsersController < ApplicationController
      require "jwt"
      include SessionHelper

      def create
        if params[:user].nil? || user_params[:access_token].nil?
          return render json: { error: "access token is missing" }, status: :bad_request
        end
        user_info = JWT.decode(user_params[:access_token], nil, false).first
        name, email, user_id, picture = user_info.values_at("name", "email", "user_id", "picture")

        user = User.new(name:, email:, id: user_id, picture: )
        if user.save!
          login(user)
          render json: { user: }, status: :ok
        elsif User.find(user_id)
          # 複製しているならエラー出す
          render json: { error: "ユーザーは既に存在します" }, status: :bad_request
        end
      end

      private

      def user_params
        params.require(:user).permit(:access_token)
      end
    end
  end
end
