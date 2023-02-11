class Post < ApplicationRecord
  belongs_to :user
  validates :pokemon_name, :version_name, :pokemon_image, :title, :content, :user_id, presence: true
end
end
