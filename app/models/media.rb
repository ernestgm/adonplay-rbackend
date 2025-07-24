class Media < ApplicationRecord
  # Associations
  has_many :slide_medias, dependent: :destroy
  has_many :slides, through: :slide_medias
  has_many :playlist_medias, dependent: :destroy
  has_many :playlists, through: :playlist_medias

  # Validations
  validates :media_type, presence: true, inclusion: { in: %w[image video audio] }
  validates :file_path, presence: true
end