class User < ApplicationRecord
  # Authentication
  has_secure_password

  # Associations
  has_many :businesses, foreign_key: 'owner_id', dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin owner] }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # Custom validation messages
  def messages
    {
      'name.required' => 'El nombre es obligatorio.',
      'name.string' => 'El nombre debe ser una cadena de texto.',
      'email.required' => 'El correo electrónico es obligatorio.',
      'email.unique' => 'El correo electrónico ya está en uso.',
      'email.format' => 'El formato del correo electrónico no es válido.',
      'role.required' => 'El rol es obligatorio.',
      'role.inclusion' => 'El rol debe ser admin o owner.',
      'password.required' => 'La contraseña es obligatoria.',
      'password.length' => 'La contraseña debe tener al menos 6 caracteres.',
      'phone.string' => 'El teléfono debe ser una cadena de texto.',
      'enabled.boolean' => 'El campo habilitado debe ser un valor booleano.'
    }
  end
end