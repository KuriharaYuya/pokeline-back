module Api
  module V1
    class ArticlesController < ApplicationController
      include SessionHelper
      # admin以外は記事を作成 & 編集できないようにする
      before_action :authenticate_user, :admin?, only: [:create, :update, :destroy]

      def index
        articles = Article.all.where(published: true)
        render json: { articles: }, status: :ok
      end

      def create
        article = current_user.articles.new(article_params)
        render json: { article: }, status: :ok if article.save!
      end

      def show
        article = Article.find(params[:id])
        # adminであれば公開していなくてもみることができる

        if article.published
          render json: { article: }, status: :ok
        elsif current_user.admin?
          render json: { article: }, status: :ok
        else
          render json: { message: "記事が公開されていません" }, status: :unauthorized
        end
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
        params.require(:article).permit(:post_id, :title, :content, :genre, :published)
      end
    end
  end
end
