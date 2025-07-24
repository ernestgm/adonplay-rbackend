class SlideMedia < ApplicationRecord
  # Associations
  belongs_to :slide
  belongs_to :media

  # Validations
  validates :slide_id, uniqueness: { scope: :media_id }
end