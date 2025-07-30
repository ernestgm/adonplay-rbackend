class DeviceValidator
  UUID_REGEX = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/
  ANDROID_ID_REGEX = /\A[0-9a-fA-F]{16}\z/

  def self.is_valid_device_id?(device_id, type: :android_id)
    return false if device_id.blank?

    case type
    when :android_id
      # Excluir el valor común de emulador si es un requisito
      return false if device_id.downcase == "9774d56d682e549c"
      device_id.match?(ANDROID_ID_REGEX)
    when :advertising_id, :uuid
      device_id.match?(UUID_REGEX)
    when :imei
      # Validar longitud y que sean solo dígitos
      return false unless device_id.match?(/\A\d+\z/) && [15, 17].include?(device_id.length)
      # Opcional: Implementar el algoritmo de Luhn para una validación más estricta
      # is_valid_luhn?(device_id) # Necesitarías implementar este método
      true # Si no usas Luhn, solo la longitud y dígitos
    when :custom_app_uuid # Si tu app genera su propio UUID
      device_id.match?(UUID_REGEX)
    else
      false # Tipo de ID desconocido
    end
  end

  # Opcional: Método para validar el algoritmo de Luhn
  def self.is_valid_luhn?(number)
    digits = number.to_s.chars.map(&:to_i)
    checksum = 0
    digits.reverse.each_with_index do |digit, i|
      if i.even?
        checksum += digit
      else
        doubled_digit = digit * 2
        checksum += (doubled_digit > 9 ? doubled_digit - 9 : doubled_digit)
      end
    end
    checksum % 10 == 0
  end
end

# Ejemplo de uso en un controlador:
# if DeviceValidator.is_valid_device_id?(params[:device_uid], type: :android_id)
#   # Continuar con el proceso de registro
# else
#   # Devolver un error: ID de dispositivo inválido
# end