class User < ApplicationRecord
  has_many :posts
  has_many :comments
  has_many :received_notifications, class_name: "Notification", foreign_key: "visited_id", dependent: :destroy
  validates :id, uniqueness: true
  has_many :articles
end
