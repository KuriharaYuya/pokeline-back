ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def sign_in_as(user)
    # userをhashに変換
    hash = user.attributes
    # idというキーをuser_idに変換
    updated_hash = hash.transform_keys { |key| key == "id" ? "user_id" : key }
    token = JWT.encode(updated_hash, nil, "none")
    post api_v1_sessions_path, params: { session: { access_token: token } }
    cookies[:user_id] = user.id
  end

  def create_user(user_obj)
    token = JWT.encode(user_obj, nil, "none")
    post api_v1_users_path, params: { user: { access_token: token } }
    JSON.parse(response.body)["user"]["id"]
  end
end
