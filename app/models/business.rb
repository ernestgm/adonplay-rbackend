class Business < ApplicationRecord
  # Associations
  has_many :slides, dependent: :destroy
  has_many :marquees, dependent: :destroy
  has_many :qrs, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :description, presence: true
end