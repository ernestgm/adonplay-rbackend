class Playlist < ApplicationRecord
  # Associations
  belongs_to :slide
  has_many :playlist_medias, dependent: :destroy
  has_many :medias, through: :playlist_medias
  belongs_to :qr, optional: true

  # Validations
  validates :name, presence: true
end