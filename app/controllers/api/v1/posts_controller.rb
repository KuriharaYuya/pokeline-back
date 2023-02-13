module Api
  module V1
    class PostsController < ApplicationController
      include SessionHelper
      before_action :authenticate_user

      def create
        post = current_user.posts.build(posts_params)
        if post.save
          render status: :ok 
        else
          render status: :unprocessable_entity
        end
      end

      def index
        posts = Post.includes(:user).sort_by(&:created_at).reverse
        posts = posts.map do |post|
          user = post.user
          {
            pokemon_name: post.pokemon_name,
            version_name: post.version_name,
            pokemon_image: post.pokemon_image,
            title: post.title,
            content: post.content,
            user_img: user.picture
          }
        end
        render json: { posts: },status: :ok
      end

      def update
        post = Post.find(posts_params[:id])
        post.update(posts_params)
        post.save
        render json: { post: },status: :ok
      end

      private

      def posts_params
        params.require(:posts).permit(:pokemon_name, :version_name, :pokemon_image, :title, :content, :id)
      end
    end
  end
end
