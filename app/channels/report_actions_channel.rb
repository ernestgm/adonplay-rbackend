class ReportActionsChannel < ApplicationCable::Channel
  def subscribed
    @device_id = self.current_device_id
    reject unless @device_id.present?

    stream_from redis_key
  end

  # Este es el método que te está faltando o fallando
  def request_screenshot(data)
    # data["body"] contendrá {"action" => "screenshot", "device_id" => "3b38290f8c2e6aec"}
    action = data["body"]["action"]
    device_id = data["body"]["device_id"]

    puts "Acción recibida: #{action} para el dispositivo: #{device_id}"

    # Aquí puedes retransmitir el mensaje a otros o ejecutar una tarea
    ActionCable.server.broadcast(redis_key, {
      action: action,
      device_id: device_id
    })
  end

  # Este es el método que te está faltando o fallando
  def ready_screenshot(data)
    # data["body"] contendrá {"action" => "screenshot", "device_id" => "3b38290f8c2e6aec"}
    action = data["body"]["action"]
    device_id = data["body"]["device_id"]
    url = data["body"]["url"]

    puts "Acción recibida: #{action} para el dispositivo: #{device_id}"

    # Aquí puedes retransmitir el mensaje a otros o ejecutar una tarea
    ActionCable.server.broadcast(redis_key, {
      action: action,
      device_id: device_id,
      url: url
    })
  end

  def speak(data)
    # data["body"] contendrá {"action" => "screenshot", "device_id" => "3b38290f8c2e6aec"}
    action = data["body"]["action"]
    device_id = data["body"]["device_id"]

    puts "Acción recibida: #{action} para el dispositivo: #{device_id}"

    # Aquí puedes retransmitir el mensaje a otros o ejecutar una tarea
    ActionCable.server.broadcast(redis_key, {
      action: action,
      device_id: device_id
    })
  end

  private

  def redis_key
    "report_channel"
  end
end
