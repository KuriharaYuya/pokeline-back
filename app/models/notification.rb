class Notification < ApplicationRecord
  include TokenGeneratable
  # actionを限定する
  action_list = %w[comment]
  validates :action, inclusion: { in: action_list }
  belongs_to :comment
  belongs_to :post
  belongs_to :visitor, class_name: "User", foreign_key: "visitor_id"
  validate :notification_receiver

  private

  def notification_receiver
    errors.add(:visited_id, "自分自身に対して通知を送ることはできません") if visitor_id == visited_id
  end
end
