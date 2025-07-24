class Marquee < ApplicationRecord
  # Associations
  belongs_to :business
  has_many :devices, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :message, presence: true
  validates :background_color, presence: true
  validates :text_color, presence: true
end