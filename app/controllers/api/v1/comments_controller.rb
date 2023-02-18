module Api
  module V1
    class CommentsController < ApplicationController
      include SessionHelper
      before_action :authenticate_user

      def create
        comment = current_user.comments.build(comments_params)
        if comment.save
          comment = Comment.includes(:user).find(comment.id)
          user = comment.user
          comment = {
            id: comment.id,
            content: comment.content,
            created_at: comment.created_at,
            user_id: user.id,
            user_name: user.name,
            user_img: user.picture
          }
          render json: { comment: }, status: :ok
        else
          render status: :unprocessable_entity
        end
      end

      def destroy
        comment = Comment.find(params[:id])
        if comment.user_id == current_user.id
          comment.destroy
          render status: :ok
        else
          render status: :unauthorized
        end
      end

      private

      def comments_params
        params.require(:comment).permit(:post_id, :content)
      end
    end
  end
end
