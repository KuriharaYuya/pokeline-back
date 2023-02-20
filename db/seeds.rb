require "faker"
# userが一人もいなければ例外を出す
if User.all.empty?
  raise "Userが一人もいません"
end
if Post.all.empty?
  raise "Postが一つもありません"
end

# userを10人作成
10.times do |n|
  tgt_user = User.create(name: Faker::Name.name, email: Faker::Internet.email, picture: Faker::Avatar.image, id: n + 1)
  tgt_user.save
end

# 一つのポストをサンプルにする
sample_post = Post.all[0]

# 50このポストを作成
50.times do |x|
  random_user = User.all[x % 10]
  post = random_user.posts.build(pokemon_name: sample_post.pokemon_name,
                                 version_name: sample_post.version_name,
                                 pokemon_image: sample_post.pokemon_image,
                                 title: "#{x}番目のポスト" + Faker::Lorem.sentence,
                                 content: Faker::Lorem.paragraph,
                                 generation_name: sample_post.generation_name)
  post.save
  #   25個のコメントを作成
  25.times do |n|
    # user1から10までがランダムで選ばれ、コメントを行う
    comment_user = User.all[n % 10]
    comment = comment_user.comments.build(post_id: post.id, content: Faker::Lorem.sentence)
    comment.save
  end
end

# User.all[0]に対して通知を作成
9.times do |n|
  noified_user = User.all.min_by(&:created_at)
  comments = noified_user.comments
  Notification.create(visitor_id: User.all[n + 1].id, visited_id: noified_user.id, post_id: comments[n].post_id, comment_id: comments[n].id, action: "comment").save!
end
