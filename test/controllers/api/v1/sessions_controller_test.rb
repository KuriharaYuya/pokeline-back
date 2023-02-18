require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    valid_user = { name: "test_user",
                   email: "test@testmail.com",
                   user_id: "itinisanshi1234",
                   picture: "https://test.picture.com/user_profile/test.jpeg" }
    @token = JWT.encode(valid_user, nil, "none")
    # create user
    post api_v1_users_path, params: { user: { access_token: @token } }
    @valid_user = User.all[0]
  end

  test "should create session with access token" do
    post api_v1_sessions_path, params: { session: { access_token: @token } }
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal @valid_user.id, json["user"]["id"]
    assert_equal @valid_user.name, json["user"]["name"]
    assert_equal @valid_user.email, json["user"]["email"]
    assert_equal @valid_user.picture, json["user"]["picture"]
    assert_equal @valid_user.id, session["user_id"]
  end

  test "should return not found with invalid access token" do
    access_token = JWT.encode({ user_id: 123 }, nil, "none")
    post api_v1_sessions_path, params: { session: { access_token: } }
    assert_response :unauthorized
  end

  test "should destroy session" do
    delete api_v1_sessions_path
    assert_response :ok
    assert_nil session["user_id"]
  end
end
