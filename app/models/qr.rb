class Qr < ApplicationRecord
  # Associations
  belongs_to :business
  has_many :devices, dependent: :nullify
  has_many :playlists, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :info, presence: true
  validates :position, presence: true
end