module Api
  module V1
    class NotificationsController < ApplicationController
      include SessionHelper
      before_action :authenticate_user

      def index
        # ユーザーに紐づいている通知を全件取得する
        notifications = current_user.received_notifications.sort_by(&:created_at).reverse
        render json: { notifications: }, status: :ok
      end

      def read
        # 通知を既読にすることpdate関数は関心を持つ

        # paramsには通知idを格納した配列が入っている
        notification_ids = params[:notification_ids]
        notification_ids.each do |id|
          Notification.find(id).update(checked: true)
        end
        render status: :ok
      end
    end
  end
end
