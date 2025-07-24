class Device < ApplicationRecord
  # Associations
  belongs_to :qr, optional: true
  belongs_to :marquee, optional: true
  belongs_to :slide, optional: true

  # Validations
  validates :name, presence: true
  validates :device_id, presence: true, uniqueness: true
end