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
        normal_user_info = { name: "normal_user",
                             email: "normal@normalmail.com",
                             id: "iamnormaluser1234",
                             picture: "https://test.picture.com/user_profile/normal.jpeg",
                             admin: false }
        @normal_user = User.new(normal_user_info)
        @normal_user.save

        @admin_user_token = JWT.encode({ user_id: admin_user_info[:id] }, nil, "none")
        # login
        sign_in_as(@admin_user)
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

      #   admingがarticleを削除してみる
      test "admin user should be able to delete article" do
        new_article_info = { title: "new_test_title", content: "new_test_content", genre: "news" }
        post api_v1_articles_path, params: { article: new_article_info }

        tgt_article = @admin_user.articles.first
        assert_difference "Article.count", -1 do
          delete api_v1_article_path(tgt_article.id)
        end
      end
      #   adminではないuserが投稿を作成できるのか？
      test "non-admin user should not be able to create article" do
        # normal_userでログイン
        sign_in_as(@normal_user)

        assert_difference "Article.count", 0 do
          post api_v1_articles_path, params: { article: { title: "iamnormal", content: "ramen", genre: "dev" } }
        end
        assert_response :unauthorized
        respone = JSON.parse(@response.body)
        message = respone["message"]
        assert_equal "admin以外は記事を作成できません", message
      end
      #   adminではないuserが投稿一覧をを見ることができるのか？
      test "non-admin user should be able to see article list" do
        ## adminが投稿を作成する
        # adminでログイン
        sign_in_as(@admin_user)

        # 投稿を作成
        published_title = "published_title"
        unpublished_title = "unpublished_title"

        post api_v1_articles_path, params: { article: { title: published_title, content: "ramenadmin", genre: "dev", published: true } }
        post api_v1_articles_path, params: { article: { title: unpublished_title, content: "ramenadmin", genre: "dev" } }

        # normal_userでログイン
        sign_in_as(@normal_user)

        # indexにアクセス
        get api_v1_articles_path
        respone = JSON.parse(@response.body)
        assert_response :ok
        assert_equal Article.all.where(published: true).length, respone["articles"].count
        # assert_equal published_title, respone["articles"].first["title"]
      end
      # adminではないuserが投稿を見ることができるのか？
      # そしてそれはpublicな投稿のみであることを確認する
      test "non-admin user should be able to see only published article" do
        ## adminが投稿を作成する
        # adminでログイン
        sign_in_as(@admin_user)

        # 投稿を作成
        published_title = "published_title"
        unpublished_title = "unpublished_title"

        post api_v1_articles_path, params: { article: { title: published_title, content: "ramenadmin", genre: "dev", published: true } }
        post api_v1_articles_path, params: { article: { title: unpublished_title, content: "ramenadmin", genre: "dev" } }

        # normal_userでログイン
        sign_in_as(@normal_user)

        published_article = Article.where(published: true).first
        get api_v1_article_path(published_article.id)
        assert_response :ok
        respone = JSON.parse(@response.body)
        assert_equal published_article.title, respone["article"]["title"]

        # adminではないuserが投稿されていない記事を見ることができないことを確認する
        tgt_article = @admin_user.articles.where(published: false).first
        get api_v1_article_path(tgt_article.id)
        assert_response :unauthorized
      end

      # adminが記事の内容を編集できるのか？
      test "admin user should be able to update article" do
        # adimnでログイン
        sign_in_as(@admin_user)
        article_info = { title: "test_title", content: "test_content", genre: "dev" }
        post api_v1_articles_path, params: { article: article_info }
        respone = JSON.parse(@response.body)
        tgt_article = Article.find(respone["article"]["id"])
        updated_article_info = { title: "updated_title", content: "updated_content", genre: "news" }
        put api_v1_article_path(tgt_article), params: { article: updated_article_info }
        respone = JSON.parse(@response.body)
        assert_equal updated_article_info[:title], respone["article"]["title"]
      end
    end
  end
end
