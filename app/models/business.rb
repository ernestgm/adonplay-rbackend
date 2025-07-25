class Business < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_many :slides, dependent: :destroy
  has_many :marquees, dependent: :destroy
  has_many :qrs, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :owner_id, presence: true
  
  # Custom validation messages
  def messages
    {
      'name.required' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'description.required' => 'La descripción es obligatoria.',
      'description.string' => 'La descripción debe ser una cadena de texto.',
      'owner_id.required' => 'El dueño es obligatorio.',
      'owner_id.exists' => 'El dueño seleccionado no existe.'
    }
  end
end