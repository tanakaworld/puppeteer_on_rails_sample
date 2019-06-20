class Article < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :cover_image, presence: true

  has_one_attached :cover_image
end
