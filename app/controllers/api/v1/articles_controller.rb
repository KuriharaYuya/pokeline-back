module Api
  module V1
    class ArticlesController < ApplicationController
      include SessionHelper
      # admin以外は記事を作成 & 編集できないようにする
      before_action :authenticate_user, :admin?, only: [:create, :update]

      def index
        articles = if !current_user.nil? && current_user.admin
                     Article.all
                   else
                     Article.all.where(published: true)
                   end
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
        # imgを確認する
        p article_params[:img]
        article.update!(article_params)
        render json: { article: }, status: :ok
      end

      def destroy
        article = Article.all.find(params[:id])
        unless current_user.admin? && article.user_id == current_user.id
          render json: { message: "あなたが作成していない記事を削除することはできません。" }, status: :unauthorized
          return
        end

        render status: :ok if article.destroy!
      end

      private

      def article_params
        params.require(:article).permit(:title, :content, :genre, :published, :img)
      end
    end
  end
end
