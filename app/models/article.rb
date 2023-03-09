class Article < ApplicationRecord
  include TokenGeneratable
  belongs_to :user

  validates :title, presence: true, length: { maximum: 30 }
  validates :img, presence: true
  validate :admin_user

  private

  def admin_user
    return errors.add(:base, "admin以外は記事を作成できません") unless user.admin

    true
  end
end
