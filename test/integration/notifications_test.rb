require "test_helper"

class NotificationsTest < ActionDispatch::IntegrationTest
  def setup
    # 通知を受け取るユーザーを作成
    notified_user_info = { name: "iAmNotifiedUser",
                           email: "test@testmail.com",
                           user_id: "iAmNotifiedUser",
                           picture: "https://test.pnotifyaifyyom/user_profile/test.jpeg" }
    notify_user_info = { name: "iAmnotifyUser",
                         email: "test@testmail.com",
                         user_id: "iamnotify",
                         picture: "https://test.pictunotifyre.com/user_profile/test.jpeg" }
    # create user
    @notified_user = User.find(create_user(notified_user_info))
    @notify_user = User.find(create_user(notify_user_info))

    # 通知を受け取るユーザーが投稿を一つ作成
    @notified_user.posts.build(pokemon_name: "aa", version_name: "adada", pokemon_image: "afad", title: "aaadad", content: "dbakda", user_id: @notified_user.id).save
    @post = Post.first
    # 通知を送るユーザーがログインする
    sign_in_as(@notify_user)

    # 通知を送るユーザーが作成した投稿にコメントをする
    @test_txt = "test_comment"
    post api_v1_comments_path, params: { comment: { post_id: @post.id, content: @test_txt } }
  end

  test "comment should create a notification" do
    assert_difference "Notification.count", 1 do
      post api_v1_comments_path, params: { comment: { post_id: @post.id, content: "test_commentyesy" } }
    end
  end

  test "notification should be associated with correct post and comment" do
    post api_v1_comments_path, params: { comment: { post_id: @post.id, content: "test is so eazy" } }
    comment = Comment.last

    sign_in_as(@notified_user)
    assert_equal comment.post_id, @notified_user.received_notifications.last.post_id
  end

  test "notification should not be created if user comments on own post" do
    sign_in_as(@notified_user)
    assert_no_difference "Notification.count" do
      post api_v1_comments_path, params: { comment: { post_id: @post.id, content: "commenting myself" } }
    end
  end

  test "notification should be marked as checked" do
    expect_checked = @notified_user.received_notifications.where(checked: false).count * -1
    assert_difference "Notification.where(checked: false).count", expect_checked do
      ids = @notified_user.received_notifications.where(checked: false).pluck(:id)
      put api_v1_notifications_path, params: { notification: { notification_ids: ids } }
    end
  end
end
