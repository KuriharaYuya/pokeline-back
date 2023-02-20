class Notification < ApplicationRecord
  include TokenGeneratable
  # actionを限定する
  action_list = %w[comment]
  validates :action, inclusion: { in: action_list }
end
