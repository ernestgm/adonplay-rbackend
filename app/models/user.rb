class User < ApplicationRecord
  # Authentication
  has_secure_password

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin owner] }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
end