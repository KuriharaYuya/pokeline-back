require "test_helper"

class NotificationsTest < ActionDispatch::IntegrationTest
  setup do
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
    @post = Post.all[0]
    # 通知を送るユーザーがログインする
    sign_in_as(@notify_user)

    # 通知を送るユーザーが作成した投稿にコメントをする
    test_txt = "test_comment"
    post api_v1_comments_path, params: { comment: { post_id: @post.id, content: test_txt } }
  end

  test "should get index" do
    # userの数が2であることを確認
    assert_equal 2, User.count
    # notified_userのpostの数が1であることを確認
    assert_equal 1, @notified_user.posts.count

    # コメントが存在するか確認
    assert_equal 1, Comment.count
    assert_equal "test_comment", Comment.all[0].content
    # 通知の数が1であることを確認
    assert_equal 1, Notification.count
    # コメントをすると通知が作成されることを確認
    assert_difference "Notification.count", 1 do
      post api_v1_comments_path, params: { comment: { post_id: @post.id, content: "test_commentyesy" } }
      @comment = JSON.parse(response.body)["comment"]
    end

    # 通知を受け取るユーザーに紐づいた通知リストから、post_id, comment_idが等しいレコードが検出できる
    post api_v1_comments_path, params: { comment: { post_id: @post.id, content: "test is so eazy" } }
    comment = Comment.all.max_by(&:created_at)

    # notified_userがログインする
    sign_in_as(@notified_user)
    assert_equal comment["post_id"], @notified_user.received_notifications.max_by(&:created_at).post_id
    # 自分でコメントした場合はその通知は作成されない
    assert_no_difference "Notification.count" do
      post api_v1_comments_path, params: { comment: { post_id: @post.id, content: "commenting myself" } }
    end
    # 通知が既読になることを確認する
    expect_checked = @notified_user.received_notifications.where(checked: false).count * -1
    assert_difference "Notification.where(checked: false).count", expect_checked do
      # 通知idsを取得
      ids = @notified_user.received_notifications.where(checked: false).map(&:id)
      put api_v1_notifications_path, params: { notification_ids: ids }
    end
  end
end
