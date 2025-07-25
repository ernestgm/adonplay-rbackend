class Playlist < ApplicationRecord
  # Associations
  belongs_to :slide
  has_many :playlist_medias, dependent: :destroy
  has_many :medias, through: :playlist_medias
  belongs_to :qr, optional: true

  # Validations
  validates :name, presence: true
  
  # Custom validation messages
  def messages
    {
      'name.required' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'slide_id.required' => 'La diapositiva es obligatoria.',
      'slide_id.exists' => 'La diapositiva seleccionada no existe.',
      'qr_id.exists' => 'El QR seleccionado no existe.'
    }
  end
end