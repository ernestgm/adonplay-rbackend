class PlaylistMedia < ApplicationRecord
  # Associations
  belongs_to :playlist
  belongs_to :media

  # Validations
  validates :playlist_id, uniqueness: { scope: :media_id }
  validates :duration, presence: true
  validates :description, presence: true
  validates :text_size, presence: true
  validates :description_position, presence: true
end