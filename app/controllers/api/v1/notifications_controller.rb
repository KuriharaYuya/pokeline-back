module Api
  module V1
    class NotificationsController < ApplicationController
      include SessionHelper
      before_action :authenticate_user

      def index
        # ログインしていなければ早期リターン
        return unless current_user

        # ユーザーに紐づいている通知を全件取得する
        # notifications = current_user.received_notifications.sort_by(&:created_at).reverse
        per_page = 10
        notifications = current_user.received_notifications.sort_by(&:created_at).reverse
        notifications = paginate(notifications, params[:page].to_i, per_page)
        # commentのuser.nameとuser.imgを含めて返す
        unchecks = current_user.received_notifications.where(checked: false).length
        notifications = notifications.map do |notification|
          visitor = notification.visitor
          {
            id: notification.id,
            comment_id: notification.comment_id,
            post_id: notification.post_id,
            post_title: notification.post.title,
            visitor_name: visitor.name,
            visitor_img: visitor.picture,
            comment_content: notification.comment.content,
            checked: notification.checked,
            created_at: notification.created_at,
          }
        end
        render json: { notifications:, unchecks: }, status: :ok
      end

      def read
        # 通知を既読にすることpdate関数は関心を持つ
        # paramsには通知idを格納した配列が入っている
        notification_ids = params[:notification][:notification_ids]
        notification_ids.each do |id|
          Notification.find(id).update(checked: true)
        end
        render status: :ok
      end

      private

      def notification_params
        params.permit(notification: { notification_ids: [] })
      end

      def paginate(array, page, per_page)
        Kaminari.paginate_array(array).page(page).per(per_page)
      end
    end
  end
end
