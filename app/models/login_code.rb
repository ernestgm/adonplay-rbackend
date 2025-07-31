class LoginCode < ApplicationRecord
  belongs_to :user, optional: true
  # Si quieres una asociación directa con el modelo Device por device_identifier:
  # belongs_to :device, foreign_key: :device_identifier, primary_key: :device_uid, optional: true
  # Nota: La línea de arriba es más compleja porque no usa la clave primaria 'id' de Device.
  # Quizás solo necesites el device_identifier y no una asociación directa de belongs_to/has_many aquí,
  # dependiendo de cómo uses el 'device_identifier' en tu modelo Device.
  # Lo más sencillo para empezar es usar el device_identifier como un string sin una association directa aquí.
  # ... Validaciones y métodos para chequear si el código ha expirado, si ha sido usado, etc.
end