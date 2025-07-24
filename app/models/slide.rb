class Slide < ApplicationRecord
  # Associations
  belongs_to :business
  has_many :playlists, dependent: :destroy
  has_many :slide_medias, dependent: :destroy
  has_many :medias, through: :slide_medias

  # Validations
  validates :name, presence: true
end