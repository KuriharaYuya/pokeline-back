module Api
  module V1
    class ArticlesController < ApplicationController
      include SessionHelper
      # admin以外は記事を作成 & 編集できないようにする
      before_action :authenticate_user, :admin?, only: [:create, :update, :destroy]

      def index
        render json: { articles: "this is teet" }, status: :ok
      end

      def create
        article = current_user.articles.new(article_params)
        render json: { article: }, status: :ok if article.save!
      end

      def update
        article = current_user.articles.find(params[:id])
        article.update!(article_params)
        render json: { article: }, status: :ok
      end

      def destroy
        article = current_user.articles.find(params[:id])
        render status: :ok if article.destroy!
      end

      private

      def article_params
        params.require(:article).permit(:post_id, :title, :content, :genre)
      end
    end
  end
end
