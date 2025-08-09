class Qr < ApplicationRecord
  # Associations
  belongs_to :business
  has_many :devices, dependent: :nullify
  has_many :slide_medias, foreign_key: 'qr_id', dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :info, presence: true
  validates :position, presence: true
  validates :business_id, presence: true

  # Custom validation messages
  def messages
    {
      'name.required' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'info.required' => 'La información es obligatoria.',
      'info.string' => 'La información debe ser una cadena de texto.',
      'position.required' => 'La posición es obligatoria.',
      'position.string' => 'La posición debe ser una cadena de texto.',
      'business_id.required' => 'El negocio es obligatorio.',
      'business_id.exists' => 'El negocio seleccionado no existe.'
    }
  end
end