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
        # ぺージネーションの実装
        posts = Kaminari.paginate_array(Post.includes(:user, :comments).sort_by(&:created_at).reverse).page(params[:page].to_i + 1).per(10)
        posts = posts.map do |post|
          user = post.user
          # commentに対して、返却数を10に制限する
          # 一度ここで、コメントを取得して、その後に、mapで返却する
          comments = Kaminari.paginate_array(post.comments.includes(:user).sort_by(&:created_at)).page(1).per(10)
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
          {
            id: post.id,
            pokemon_name: post.pokemon_name,
            version_name: post.version_name,
            generation_name: post.generation_name,
            pokemon_image: post.pokemon_image,
            title: post.title,
            content: post.content,
            user_img: user.picture,
            user_id: user.id,
            user_name: user.name,
            comments:,
            comments_length: post.comments.length
          }
        end
        render json: { posts: }, status: :ok
      end

      def update
        post = Post.includes(:user).find(params[:id])
        post.update(posts_params)
        post.save
        user = current_user
        post = {
          id: post.id,
          pokemon_name: post.pokemon_name,
          version_name: post.version_name,
          generation_name: post.generation_name,
          pokemon_image: post.pokemon_image,
          title: post.title,
          content: post.content,
          user_img: user.picture,
          user_id: user.id,
          user_name: user.name
        }
        render json: { post: }, status: :ok
      end

      def destroy
        post = Post.find(params[:id])
        if current_user == post.user
          render status: :ok if post.destroy!
        else
          render status: :unauthorized
        end
      end

      private

      def posts_params
        params.require(:posts).permit(:pokemon_name, :version_name, :pokemon_image, :title, :content, :id, :generation_name)
      end
    end
  end
end
