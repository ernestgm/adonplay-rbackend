class SlideMedia < ApplicationRecord
  # Associations
  belongs_to :slide
  belongs_to :media
  belongs_to :audio_media, class_name: 'Media', optional: true
  belongs_to :qr, optional: true

  # Validations
  validates :slide_id, uniqueness: { scope: :media_id }
  validates :order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :audio_media_id, presence: false
  validates :qr_id, presence: false
  validates :description, presence: false
  validates :text_size, presence: false
  validates :description_position, presence: false
  
  # Validate that audio_media is only assigned to image media
  validate :audio_media_only_for_images
  
  # Custom validation messages
  def messages
    {
      'slide_id.required' => 'La diapositiva es obligatoria.',
      'media_id.required' => 'El medio es obligatorio.',
      'order.required' => 'El orden es obligatorio.',
      'order.numericality' => 'El orden debe ser un número entero mayor o igual a 0.',
      'duration.required' => 'La duración es obligatoria.',
      'duration.numericality' => 'La duración debe ser un número entero mayor que 0.',
      'audio_media_id.exists' => 'El audio seleccionado no existe.',
      'qr_id.exists' => 'El QR seleccionado no existe.'
    }
  end
  
  private
  
  def audio_media_only_for_images
    if audio_media.present? && media.media_type != 'image'
      errors.add(:audio_media_id, 'Solo se puede asignar audio a medios de tipo imagen')
    end
    
    if audio_media.present? && audio_media.media_type != 'audio'
      errors.add(:audio_media_id, 'El medio asignado como audio debe ser de tipo audio')
    end
  end
end