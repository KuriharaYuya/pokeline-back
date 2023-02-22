require "test_helper"

module Api
  module V1
    class ArticlesControllerTest < ActionDispatch::IntegrationTest
      def setup
        admin_user_info = { name: "test_user",
                            email: "test@testmail.com",
                            id: "itinisanshi1234",
                            picture: "https://test.picture.com/user_profile/test.jpeg",
                            admin: true }
        @admin_user = User.new(admin_user_info)
        @admin_user.save
        @admin_user_token = JWT.encode({ user_id: admin_user_info[:id] }, nil, "none")
        # login
        cookies[:user_id] = @admin_user.id
        post api_v1_sessions_path, params: { session: { access_token: @admin_user_token } }
      end

      test "admin user should be exist" do
        post api_v1_sessions_path, params: { session: { access_token: @admin_user_token } }
        assert_response :ok
        respone = JSON.parse(@response.body)
        # adminであるuserが存在しているか
        assert_equal @admin_user.id, respone["user"]["id"]
        assert_equal true, respone["user"]["admin"]

        # adminでログインしているか
        assert_equal @admin_user.id, cookies[:user_id]
      end

      # adminがarticleを作成してみる
      test "admin user should be able to create article" do
        article_info = { title: "test_title", content: "test_content", genre: "dev" }
        assert_difference "Article.count", 1 do
          post api_v1_articles_path, params: { article: article_info }
        end
        assert_response :ok
        respone = JSON.parse(@response.body)
        # titleが一致しているか
        assert_equal article_info[:title], respone["article"]["title"]
      end

      #   admingがarticleを編集してみる

      test "admin user should be able to update article" do
        new_article_info = { title: "new_test_title", content: "new_test_content", genre: "news" }
        post api_v1_articles_path, params: { article: new_article_info }

        assert_response :ok
        respone = JSON.parse(@response.body)
        # titleが一致しているか
        assert_equal new_article_info[:title], respone["article"]["title"]
      end

      #   admingがarticleを削除してみる
      test "admin user should be able to delete article" do
        new_article_info = { title: "new_test_title", content: "new_test_content", genre: "news" }
        post api_v1_articles_path, params: { article: new_article_info }

        tgt_article = @admin_user.articles.first
        assert_difference "Article.count", -1 do
          delete api_v1_article_path(tgt_article.id)
        end
      end
    end
  end
end
