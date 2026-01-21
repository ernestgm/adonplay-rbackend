class StatusActionsChannel < ApplicationCable::Channel
  def subscribed
    @device_id = current_device_id
    return reject if @device_id.blank?

    # 1. Primero nos unimos al stream
    stream_from redis_key

    if android_device?
      update_presence
    end

    # 2. Enviamos la lista inicial (solo a este cliente)
    # Usamos all_active_devices para que sea coherente con el heartbeat
    transmit({ devices: all_active_devices })
  end

  def unsubscribed
    if android_device?
      # Eliminamos rastro inmediato al desconectar
      $redis.del("presence:#{@device_id}")
      $redis.srem("devices_set", @device_id)
      broadcast_devices
    end
  end

  def receive(data)
    if data["action"] == "receive"
      update_presence if android_device?
    end
      # Reenviamos mensajes normales a todos

    data["device_id"] = current_device_id
    ActionCable.server.broadcast(redis_key, data)
  end

  private

  def redis_key
    "status_channel"
  end

  def android_device?
    current_device_id != "frontend"
  end

  def update_presence
    # TTL de 60 segundos
    $redis.setex("presence:#{@device_id}", 60, "active")
    $redis.sadd("devices_set", @device_id)
    broadcast_devices
  end

  def all_active_devices
    all_ids = $redis.smembers("devices_set")
    # Solo devolvemos los que no han expirado
    all_ids.select { |id| $redis.exists?("presence:#{id}") }
  end

  def broadcast_devices
    # IMPORTANTE: Usar la misma lista filtrada para el broadcast
    ActionCable.server.broadcast(redis_key, { devices: all_active_devices })
  end
end