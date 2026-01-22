class Media < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User', optional: true
  has_many :slide_medias, dependent: :destroy
  has_many :slides, through: :slide_medias
  has_many :audio_slide_medias, class_name: 'SlideMedia', foreign_key: 'audio_media_id', dependent: :nullify

  # Validations
  validates :media_type, presence: true, inclusion: { in: %w[image video audio] }
  validates :file_path, presence: false
  validates :owner_id, presence: true
  validates :json_path, presence: true, if: :is_editable?
  validate :is_editable_only_for_images

  before_validation :clear_json_path_if_not_editable

  # Scopes
  scope :images, -> { where(media_type: 'image') }
  scope :videos, -> { where(media_type: 'video') }
  scope :audios, -> { where(media_type: 'audio') }
  
  # Custom validation messages
  def messages
    {
      'media_type.required' => 'El tipo de medio es obligatorio.',
      'media_type.inclusion' => 'El tipo de medio debe ser imagen, video o audio.',
      'file_path.required' => 'La ruta del archivo es obligatoria.',
      'file_path.string' => 'La ruta del archivo debe ser una cadena de texto.',
      'owner_id.exists' => 'El usuario dueño debe existir.',
      'json_path.required' => 'La ruta del JSON es obligatoria cuando la imagen es editable.',
      'is_editable.invalid_type' => 'Solo las imágenes pueden ser editables.'
    }
  end

  private

  def is_editable_only_for_images
    if is_editable && media_type != 'image'
      errors.add(:is_editable, messages['is_editable.invalid_type'])
    end
  end

  def clear_json_path_if_not_editable
    self.json_path = nil unless is_editable
  end
end