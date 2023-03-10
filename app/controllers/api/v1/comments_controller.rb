module Api
  module V1
    class CommentsController < ApplicationController
      include SessionHelper
      before_action :authenticate_user
      skip_before_action :authenticate_user, only: [:index]

      def index
        comments = Comment.includes(:user).where(post_id: params[:post_id]).page(params[:page].to_i + 1).per(10)
        comments = comments.map do |comment|
          user = comment.user
          {
            id: comment.id,
            content: comment.content,
            created_at: comment.created_at,
            user_id: user.id,
            user_name: user.name,
            user_img: user.picture
          }
        end
        render json: { comments: }, status: :ok
      end

      def create
        unless current_user
          render json: { error: "ログインしてください" }, status: :unauthorized
          return
        end
        comment = current_user.comments.build(comments_params)
        if comment.save
          post = Post.find(comments_params["post_id"])
          if post.user_id != current_user.id
            Notification.new(visitor_id: comment.user_id, visited_id: post.user_id, post_id: post.id, comment_id: comment.id, action: "comment").save
          end
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
