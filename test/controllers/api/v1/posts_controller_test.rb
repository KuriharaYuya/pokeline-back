require "test_helper"

class Api::V1::PostsControllerTest < ActionDispatch::IntegrationTest
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
end
