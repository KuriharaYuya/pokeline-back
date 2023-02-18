require "test_helper"

module Api
  module V1
    class PostsControllerTest < ActionDispatch::IntegrationTest
      def setup
        valid_user = { name: "test_user",
                       email: "test@testmail.com",
                       user_id: "itinisanshi1234",
                       picture: "https://test.picture.com/user_profile/test.jpeg" }
        @token = JWT.encode(valid_user, nil, "none")
        # create user
        post api_v1_users_path, params: { user: { access_token: @token } }
        @valid_user = User.all[0]

        # login
        cookies[:user_id] = @valid_user.id
        post api_v1_sessions_path, params: { session: { access_token: @token } }

        # create post
        post api_v1_posts_path, params: { posts: { pokemon_name: "aa", version_name: "adada", pokemon_image: "afad", title: "aaadad", content: "dbakda" } }
      end

      test "create post" do
        assert_difference "Post.count", 1 do
          post api_v1_posts_path, params: { posts: { pokemon_name: "aa", version_name: "adada", pokemon_image: "afad", title: "aaadad", content: "dbakda" } }
          assert_response :ok
        end
      end

      test "create post with blank column" do
        assert_no_difference "Post.count" do
          post api_v1_posts_path, params: { posts: { pokemon_name: "aa", version_name: "adada", pokemon_image: "afad", title: "", content: "" } }
          assert_response :unprocessable_entity
        end
      end

      test "destory post" do
        tgt_post = Post.all.first
        assert_difference "Post.count", -1 do
          delete api_v1_post_path(tgt_post)
        end
      end

      test "trying destory post by invalid user" do
        tgt_post = Post.all.first
        cookies[:user_id] = 100
        assert_no_difference "Post.count" do
          delete api_v1_post_path(tgt_post)
        end
        assert_response :unauthorized
      end

      test "update post" do
        tgt_post = Post.all.first
        test_title = "test_title"
        test_content = "test_content"
        put api_v1_post_path(tgt_post), params: { posts: { title: test_title, content: test_content } }
        assert_response :ok
        json = JSON.parse(response.body)
        assert_equal json["post"]["title"], test_title
        assert_equal json["post"]["content"], test_content
      end

      test "get posts" do
        get api_v1_posts_path
        assert_response :ok
        response_json = JSON.parse(response.body)
        assert_equal response_json["posts"].length, Post.all.length
      end
    end
  end
end
