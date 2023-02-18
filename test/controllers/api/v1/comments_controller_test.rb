require "test_helper"

module Api
  module V1
    class CommentsControllerTest < ActionDispatch::IntegrationTest
      def setup
        valid_user1 = { name: "test_user1",
                        email: "test@testmail1.com",
                        user_id: "itinisanshi1234",
                        picture: "https://test.picture.com/user_profile/test.jpeg" }
        valid_user2 = { name: "test_user2",
                        email: "test@testmail2.com",
                        user_id: "itinisanshi1234oohahahahaa",
                        picture: "https://test.picture.com/user_profile/se---itest.jpeg" }
        @token1 = JWT.encode(valid_user1, nil, "none")
        @token2 = JWT.encode(valid_user2, nil, "none")
        # create user1
        post api_v1_users_path, params: { user: { access_token: @token1 } }
        @valid_user1 = User.all[0]

        # create user2
        post api_v1_users_path, params: { user: { access_token: @token2 } }
        @valid_user2 = User.all[1]

        # login with user1
        cookies[:user_id] = @valid_user1.id
        post api_v1_sessions_path, params: { session: { access_token: @token1 } }

        # user1 create post
        post api_v1_posts_path, params: { posts: { pokemon_name: "aa", version_name: "adada", pokemon_image: "afad", title: "aaadad", content: "dbakda" } }

        # login with user2
        cookies[:user_id] = @valid_user2.id
        post api_v1_sessions_path, params: { session: { access_token: @token2 } }
      end

      test "create comment" do
        test_txt = "test_comment"
        assert_difference "Comment.count", 1 do
          post api_v1_comments_path, params: { comment: { post_id: Post.all[0].id, content: test_txt } }
        end
        assert_response :ok
        json = JSON.parse(response.body)
        assert_equal test_txt, json["comment"]["content"]
        assert_equal @valid_user2.id, json["comment"]["user_id"]
      end

      test "delete comment" do
        # create comment
        post api_v1_comments_path, params: { comment: { post_id: Post.all[0].id, content: "test_comment" } }

        tgt_comment = @valid_user2.comments.first
        assert_difference "Comment.count", -1 do
          delete api_v1_comment_path(tgt_comment.id)
        end
        assert_response :ok
      end

      test "trying to delete other user's comment" do
        # comment is created by user1
        comment = Comment.new(post_id: Post.all[0].id, user_id: @valid_user1.id, content: "test_comment")
        comment.save

        # user2 tries to delete user1's comment
        tgt_comment = @valid_user1.comments.first
        assert_no_difference "Comment.count" do
          delete api_v1_comment_path(tgt_comment.id)
        end
        assert_response :unauthorized
      end
    end
  end
end
