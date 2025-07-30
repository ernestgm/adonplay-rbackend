class Device < ApplicationRecord
  # Associations
  belongs_to :qr, optional: true
  belongs_to :marquee, optional: true
  belongs_to :slide, optional: true
  belongs_to :users, class_name: 'User', optional: true

  # Validations
  validates :name, presence: true
  validates :device_id, presence: true, uniqueness: true
  
  # Custom validation messages
  def messages
    {
      'name.required' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'device_id.required' => 'El ID del dispositivo es obligatorio.',
      'device_id.unique' => 'El ID del dispositivo ya está en uso.',
      'qr_id.exists' => 'El QR seleccionado no existe.',
      'marquee_id.exists' => 'El marquesina seleccionada no existe.',
      'slide_id.exists' => 'La diapositiva seleccionada no existe.'
    }
  end
end