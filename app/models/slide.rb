class Slide < ApplicationRecord
  # Associations
  belongs_to :business
  has_many :devices, foreign_key: 'slide_id', dependent: :nullify
  has_many :slide_medias, dependent: :destroy
  has_many :medias, through: :slide_medias

  # Validations
  validates :name, presence: true
  validates :business_id, presence: true
  validates :description, presence: false
  validates :description_position, presence: false
  validates :description_size, presence: false

  # Custom validation messages
  def messages
    {
      'name.presence' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'business_id.presence' => 'El negocio es obligatorio.',
      'business_id.exists' => 'El negocio seleccionado no existe.'
    }
  end
end