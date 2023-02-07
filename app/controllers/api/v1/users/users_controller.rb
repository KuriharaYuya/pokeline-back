module Api
  module V1
    module Users
      class UsersController < ApplicationController
        def test
          render json: { test: "test is so good" }, status: :ok
        end
      end
    end
  end
end
