require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_user = { name: "test_user",
                    email: "test@testmail.com",
                    user_id: "itinisanshi1234",
                    picture: "https://test.picture.com/user_profile/test.jpeg" }
    @token = JWT.encode(@valid_user, nil, "none")
  end

  test "test creation of user " do
    assert_difference "User.count", 1 do
      post api_v1_users_path, params: { user: { access_token: @token } }
    end
    assert_response :ok
    assert_equal @valid_user[:name], JSON.parse(response.body)["user"]["name"]
  end

  test "test failer with duplicated user" do
    post api_v1_users_path, params: { user: { access_token: @token } }

    assert_raise ActiveRecord::RecordInvalid do
      post api_v1_users_path, params: { user: { access_token: @token } }
    end
  end
  test "test failure with missing access_token" do
    post api_v1_users_path, params: { user: { access_token: nil } }
    assert_response :bad_request
    assert_equal "access token is missing", JSON.parse(response.body)["error"]
  end
end
