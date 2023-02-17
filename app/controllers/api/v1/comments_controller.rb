module Api
  module V1
    class CommentsController < ApplicationController
      include SessionHelper
      before_action :authenticate_user

      def create
        comment = current_user.comments.build(comments_params)
        if comment.save
          render json: { comment: }, status: :ok
        else
          render status: :unprocessable_entity
        end
      end

      private

      def comments_params
        params.require(:comment).permit(:post_id, :content)
      end
    end
  end
end
