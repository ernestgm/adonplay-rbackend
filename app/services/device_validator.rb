class DeviceValidator
  UUID_REGEX = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/
  ANDROID_ID_REGEX = /\A[0-9a-fA-F]{13,16}\z/

  def self.is_valid_device_id?(device_id)
    return false if device_id.blank?
    return true
  end

  # Valida un número completo usando el algoritmo de Luhn
  def self.is_valid_luhn?(number)
    Luhn.valid?(number)
  end

  # Genera un número de Luhn válido a partir de un número base
  def self.generate_luhn()
    Luhn.generate(8)
  end
end

# Ejemplo de uso en un controlador:
# if DeviceValidator.is_valid_device_id?(params[:device_uid], type: :android_id)
#   # Continuar con el proceso de registro
# else
#   # Devolver un error: ID de dispositivo inválido
# end