class Marquee < ApplicationRecord
  # Associations
  belongs_to :business
  has_many :devices, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :message, presence: true
  validates :background_color, presence: true
  validates :text_color, presence: true
  
  # Custom validation messages
  def messages
    {
      'name.required' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'message.required' => 'El mensaje es obligatorio.',
      'message.string' => 'El mensaje debe ser una cadena de texto.',
      'background_color.required' => 'El color de fondo es obligatorio.',
      'background_color.string' => 'El color de fondo debe ser una cadena de texto.',
      'text_color.required' => 'El color del texto es obligatorio.',
      'text_color.string' => 'El color del texto debe ser una cadena de texto.',
      'business_id.required' => 'El negocio es obligatorio.',
      'business_id.exists' => 'El negocio seleccionado no existe.'
    }
  end
end