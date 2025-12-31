class WdStatusActionsChannel < ApplicationCable::Channel
  def subscribed
    @device_id = self.current_device_id
    reject unless @device_id.present?

    group_key = redis_key

    if android_device?
      $redis.sadd(redis_key, connection.device_id)
      broadcast_devices
    end

    # Enviar lista inicial solo a este cliente
    transmit({ devices: $redis.smembers(group_key) })
    stream_from group_key
    # stream_for @device_id
  end

  def unsubscribed
    if android_device?
      device_id = self.current_device_id
      $redis.srem(redis_key, device_id)
      broadcast_devices
    end
  end

  private

  def redis_key
    "wd_status_channel"
  end

  def android_device?
    self.current_device_id != "frontend"
  end

  def broadcast_devices
    devices = $redis.smembers(redis_key)
    ActionCable.server.broadcast(redis_key, { devices: devices })
  end
end
