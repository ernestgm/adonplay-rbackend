# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :device_id # Ahora identificamos por app_id

    def connect
      self.device_id = find_verified_device_id
      # Opcional: Rechazar la conexión si el app_id no es válido
      reject_unauthorized_connection unless self.device_id
    end

    private

    def find_verified_device_id
      # Tu lógica para verificar y obtener el app_id
      # Puede venir de un parámetro URL al establecer la conexión WebSocket
      # Ejemplo: ws://localhost:3000/cable?app_id=tu_app_id_unico
      if request.params[:device_id].present? && DevicesVerifyCodes.find_by(device_id: request.params[:device_id]) # Asegúrate de que tu modelo App exista
        request.params[:device_id]
      else
        nil # O maneja el error de otra manera
      end
    end
  end
end
