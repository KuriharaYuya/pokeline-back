class Comment < ApplicationRecord
  include TokenGeneratable
  belongs_to :user
  belongs_to :post
end
