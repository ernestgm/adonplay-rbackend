class Media < ApplicationRecord
  # Associations
  has_many :slide_medias, dependent: :destroy
  has_many :slides, through: :slide_medias
  has_many :playlist_medias, dependent: :destroy
  has_many :playlists, through: :playlist_medias

  # Validations
  validates :media_type, presence: true, inclusion: { in: %w[image video audio] }
  validates :file_path, presence: true
  
  # Custom validation messages
  def messages
    {
      'media_type.required' => 'El tipo de medio es obligatorio.',
      'media_type.inclusion' => 'El tipo de medio debe ser imagen, video o audio.',
      'file_path.required' => 'La ruta del archivo es obligatoria.',
      'file_path.string' => 'La ruta del archivo debe ser una cadena de texto.'
    }
  end
end